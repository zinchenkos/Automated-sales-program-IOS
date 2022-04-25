import json
import pymysql.cursors
import os
import logg
import jwt
from datetime import datetime, timedelta
from os import getenv


JWT_SECRET = 'secret'
JWT_ALGORITHM = 'HS256'
JWT_EXP_DELTA_SECONDS = 20



HOST_MYSQL = '127.0.0.1'
PORT_MYSQL = 3306
USER_MYSQL = 'root'
PASSWORD_MYSQL = 'boyko172839465'
DB_MYSQL = 'product_new1'
CHARSET_MYSQL = 'utf8mb4'
CURSORCLASS_MYSQL = pymysql.cursors.DictCursor

'''
HOST_MYSQL = '127.0.0.1'
PORT_MYSQL = 3305
USER_MYSQL = 'root'
PASSWORD_MYSQL = '12345678'
DB_MYSQL = 'product_new1'
CHARSET_MYSQL = 'utf8mb4'
CURSORCLASS_MYSQL = pymysql.cursors.DictCursor
'''



class MySqlCon:

    _instance = None

    @staticmethod
    def get_instance():
        if MySqlCon._instance is None:
            MySqlCon._instance = MySqlCon()
        return MySqlCon._instance

    def __init__(self):

        self._mysql_con = {
        "host": getenv("HOST_MYSQL", HOST_MYSQL),
        "port": getenv("PORT_MYSQL", PORT_MYSQL),
        "user": getenv("USER_MYSQL", USER_MYSQL),
        "password": (getenv("PASSWORD_MYSQL", PASSWORD_MYSQL)),
        "db": getenv("DB_MYSQL", DB_MYSQL),
        "charset": getenv("CHARSET_MYSQL", CHARSET_MYSQL),
        "cursorclass": getenv("CURSORCLASS_MYSQL", CURSORCLASS_MYSQL),
        }
        
        self.log = logg.get_class_log(self)

        self.log.debug("Trying to connect to My SQL {host}:{port}/{db}" , extra=self._mysql_con)
        self.connection= pymysql.connect(**self._mysql_con)
        self.log.info("Successfully connect to My SQL {host}:{port}/{db}" , extra=self._mysql_con)


    def search_barcode(self, barcode):
        data_dict = None
        self.log.debug("Trying to find barcode : {barcode}", extra={'barcode' : barcode})
        try:
            with self.connection.cursor() as cursor:
                sql = "SELECT id_product_value,name,bordercode,price,photo,points  from product_new1.product_value where  bordercode =%s"
                cursor.execute(sql, (barcode))

                rv = cursor.fetchall()

                if cursor.rowcount > 1:
                    raise self.TooManyObjects

                elif cursor.rowcount == 0:
                    raise self.DoesNotExist


                else:
                    data_json = json.dumps(rv, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict = data
                   

        except:
            self.log.exception('Error on SELECT product by barcode : {barcode}',extra={'barcode' : barcode})
        return data_dict
      

    def search_user(self,email,password) :
        data_dict = None
        print(password)
        self.log.debug("Trying to find email(with password) : {email}", extra={'email' : email})
        try:

            with self.connection.cursor() as cursor:

                sql = "SELECT * FROM product_new1.user WHERE email=%s AND password=%s"
                cursor.execute(sql, (email, password))

                rv = cursor.fetchall()



                if cursor.rowcount > 1:
                    
                    raise self.TooManyObjects
                elif cursor.rowcount == 0:
                  
                    raise self.DoesNotExist
                else:
                    data_json = json.dumps(rv, indent=4, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict = data
                    
        except:
            self.log.exception('Error on SELECT user by email : {email}',extra={'email' : email})

        return data_dict
        
    def write_token(self, email, password, token):
        self.log.debug("Trying to write token for user with email: {email}", extra={'email' : email})
        try:

            with self.connection.cursor() as cursor:
                    sql1="UPDATE product_new1.user SET token=%s where user.email=%s AND user.password=%s"
                    cursor.execute(sql1,(token,email, password))
                    self.connection.commit()
        except:
            self.log.exception('Cannot token token for user with email: {email}', extra={'email' : email})

        return "ok"


    def check_email(self, email):
        data_dict = None
        self.log.debug("Trying to find email : {email}", extra={'email' : email})
        try:

            with self.connection.cursor() as cursor:

                sql = "SELECT * FROM product_new1.user WHERE email=%s"
                cursor.execute(sql, (email))

                rv = cursor.fetchall()
                if cursor.rowcount > 0:
                    raise self.DoesNotExist        
        
        except:
            self.log.exception('Error on SELECT user by email : {email}',extra={'email' : email})
            raise Exception("Email is not new")


    
    def search_admin(self,barcode,password) :
        self.log.debug('Trying to find admin with : {barcode}',extra={'barcode' : barcode})
        data_dict = None
        try:

            with self.connection.cursor() as cursor:

                sql = "SELECT * FROM product_new1.admin WHERE bordercode=%s AND password=%s"
                cursor.execute(sql, (barcode, password))

                rv = cursor.fetchall()



                if cursor.rowcount > 1:
                    
                    raise self.TooManyObjects
                elif cursor.rowcount == 0:
                        sql = "SELECT * FROM product_new1.admin WHERE bordercode=%s"
                        cursor.execute(sql, barcode)
                        if cursor.rowcount != 0:
                            raise self.NotCorrectPassword
                        else:
                        
                            raise self.DoesNotExist
                else:
                    data_json = json.dumps(rv, indent=4, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict = data

        except:
            raise Exception("Cannot find admin")
            self.log.exception('Cannot find admin with : {barcode}',extra={'barcode' : barcode})

        return data_dict


    def search_user_bool(self,barcode) -> bool:
        self.log.debug('Trying to find user with : {barcode}',extra={'barcode' : barcode})
        try:

            with self.connection.cursor() as cursor:

                sql = "SELECT * FROM product_new1.user WHERE bordercode=%s"
                cursor.execute(sql, (barcode))

                rv = cursor.fetchall()
                if cursor.rowcount > 0 :
                    return True
                else: return False

        except:
            self.log.exception('User {barcode} is absent',extra={'barcode' : barcode})
            return False



    class DoesNotExist(BaseException):
        pass

    class TooManyObjects(BaseException):
        pass
    
    class NoToken(BaseException):
        pass
        
    def relative_subcategory(self, category):
        self.log.debug("Trying to display the list of subcategories for selected category")
        data_dict = {}
        try:
             with self.connection.cursor() as cursor:
                sql = "SELECT product_subcategory.id_subcategory, product_subcategory.name from product_new1.product_category,product_new1.product_subcategory where product_category.name = %s and product_subcategory.id_category=product_category.id_category"
                cursor.execute(sql, (category))
                rv = cursor.fetchall()

                if cursor.rowcount == 0:
                    print("34")
                    raise self.DoesNotExist
                else:
                    data_json = json.dumps(rv, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict.update({data.get("id_subcategory") : data.get("name")})
                  
        except:
            self.log.exception('Looks like there is no subcategories for selected category')
        return data_dict
    
    def manufacturer_list(self,category):
        self.log.debug("Trying to display the list of manufacturers for selected category")
        data_dict = {}
        try:
             with self.connection.cursor() as cursor:
                sql = "SELECT product_manufacturer.id_manufacturer, product_manufacturer.name from product_new1.product_manufacturer, product_new1.product_category where product_category.name = %s and product_manufacturer.id_category=product_category.id_category"
                cursor.execute(sql, (category))
                rv = cursor.fetchall()
                
                if cursor.rowcount == 0:
                    print("34")
                    raise self.DoesNotExist
                else:
                    data_json = json.dumps(rv, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict.update({data.get("id_manufacturer") : data.get("name")})
                   
        except:
            self.log.exception('Looks like there is no manufacturers for selectd category')
        return data_dict
    
    def checkbarcode(self,barcode):
        self.log.debug("Trying to find product with barcode: {barcode}", extra={'barcode':barcode})
        try:
            with self.connection.cursor() as cursor:
                sql0 = "SELECT *  from product_new1.product_value where  bordercode =%s"
                cursor.execute(sql0, (barcode))
                rv = cursor.fetchall()
                if cursor.rowcount > 0:
                    raise self.DoesNotExist
        except:
            self.log.exception('Barcode {barcode} exists', extra={'barcode':barcode})
            raise Exception("has barcode")
    
    def checktoken(self,token):
        self.log.debug("Trying to find user with token: {token}", extra={'token':token})
        try:
            with self.connection.cursor() as cursor:
                sql0 = "SELECT *  from product_new1.user where  token =%s"
                cursor.execute(sql0, (token))
                rv = cursor.fetchall()
                if cursor.rowcount == 0:
                    raise self.NoToken
                if cursor.rowcount == 1:
                    self.log.debug("Token exists", extra={'token':token})
        except:
            self.log.exception('Token not exists', extra={'token':token})
            raise Exception("Token not exists")

    def rowcount(self):
        self.log.debug("Trying to count how many products we have in DB")
        try:
            with self.connection.cursor() as cursor:
                sql0 = "SELECT *  from product_new1.product_value"
                cursor.execute(sql0)
                rv = cursor.fetchall()
                if cursor.rowcount == 0:
                    raise self.DoesNotExist
                return {'rowcount' : str(cursor.rowcount)}    
        except:
            self.log.exception('Something went wrong, check DB and try again')
            raise Exception("no row")


    def listProduct(self, startLimit : int, countProduct : int):
        self.log.debug("Trying to display the list of products")
        try:
            data_dict = {}
            
            print(startLimit)
            print(countProduct)
            with self.connection.cursor() as cursor:
                
                sql0 = "SELECT id_product_value, product_value.name,bordercode,price,photo,points, product_category.name as 'category' ,product_subcategory.name as 'subcategory' , product_manufacturer.name as 'manufacturer' ,delivery_date,quantity from product_new1.product_value , product_new1.product_category, product_new1.product_subcategory ,product_new1.product_manufacturer where product_value.id_category=product_category.id_category And product_value.id_manufacturer = product_manufacturer.id_manufacturer and product_value.id_subcategory = product_subcategory.id_subcategory limit %s,%s "
                cursor.execute(sql0, (int(startLimit),int(countProduct)))
                rv = cursor.fetchall()
    
                if cursor.rowcount == 0:
                    raise self.DoesNotExist
                else:
                    data_json = json.dumps(rv, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        print(data)
                        data_dict.update({data.get("id_product_value") : data})
                       
        except:
            self.log.exception('Looks like this products are absent')
            raise Exception("no row") 

        return data_dict           
        

    def add_row_to_user (self,barcode,name,phone,email, password):
        self.log.debug("Trying to add user with email : {email}", extra={'email' : email})
        try:
            with self.connection.cursor() as cursor:
                MySqlCon.get_instance().checkbarcode(barcode)
                sql = "INSERT INTO product_new1.user (bordercode, name, phone, email, password) VALUES (%s, %s, %s, %s, %s)"
                cursor.execute(sql, (barcode,name, phone, email, password))
                self.connection.commit()
        except:
            self.log.exception('There was a problem while adding user, check your data')
        return "ok"



    def add_row_to_products(self,name,barcode,price,id_subcategory,id_manufacturer, delivery_date, quantity):
        self.log.debug("Trying to add product with barcode : {barcode}", extra={'barcode' : barcode})
        try:
            with self.connection.cursor() as cursor:
                MySqlCon.get_instance().checkbarcode(barcode)
                sql = "Insert into product_new1.product_value(name, bordercode, price,id_subcategory, id_manufacturer, delivery_date, quantity) values (%s, %s, %s, %s, %s, %s, %s) "

                cursor.execute(sql, (name,barcode, price, id_subcategory, id_manufacturer, delivery_date, quantity))
                self.connection.commit()

                '''sql1 = "SELECT * FROM product_new1.product_value where bordercode = %s"
                cursor.execute(sql1, (barcode))
                rv = cursor.fetchall()
                if cursor.rowcount > 1:
                    print("545")
                    raise self.TooManyObjects
                elif cursor.rowcount == 0:
                    print("34")
                    raise self.DoesNotExist
                else:
                    data_json = json.dumps(rv, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict = data
                   # print(data)
                    #print(json.dumps(data, ensure_ascii=False, separators=(',', ': ')))'''

        except:
            self.log.exception('There was a problem while adding  product, check your data')
        return "ok"

    def add_features_value(self, value, id_feature, barcode):
        self.log.debug("Trying to add feature values for product with barcode : {barcode}", extra={'barcode' : barcode})
        try:
            with self.connection.cursor() as cursor:
            
                
               
                sql = "Insert into product_new1.product_features_value(value, id_feature, id_product) values (%s, %s, (SELECT product_value.id_product_value from product_new1.product_value where product_value.bordercode = %s)) "

                cursor.execute(sql, (value,id_feature, barcode))
                self.connection.commit()

                

        except:
            self.log.exception('There was a problem while adding feature values for product {barcode}, check your data', extra={'barcode' : barcode})
        return "added"
            
    def search_barcode_moreinfo(self, barcode):
        self.log.debug("Trying to get info for product with barcode : {barcode}", extra={'barcode' : barcode})
        data_dict = None
        try:
            with self.connection.cursor() as cursor:
                sql = "SELECT id_product_value, product_value.name,bordercode,price,photo,points, product_category.name as 'category' ,product_subcategory.name as 'subcategory' , product_manufacturer.name as 'manufacturer' ,delivery_date,quantity from product_new1.product_value , product_new1.product_category, product_new1.product_subcategory ,product_new1.product_manufacturer where product_value.id_category=product_category.id_category And product_value.id_manufacturer = product_manufacturer.id_manufacturer and product_value.id_subcategory = product_subcategory.id_subcategory and  product_value.bordercode =%s"
                cursor.execute(sql, (barcode))

                rv = cursor.fetchall()

                if cursor.rowcount > 1:
                    
                    raise self.TooManyObjects
                elif cursor.rowcount == 0:
          
                    raise self.DoesNotExist
                else:
                    data_json = json.dumps(rv, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict = data
                   
        except:
            self.log.exception("No info for product with barcode : {barcode} or it`s not exist", extra={'barcode' : barcode})

        return data_dict
    
    def user_info(self, id_user):
        self.log.debug("Trying to get info about user with id: {id_user}", extra={'id_user' : id_user})
        data_dict = None
        try:
            with self.connection.cursor() as cursor:
                sql = 'SELECT user.bordercode as "barcode", user.name as "name", user.phone as "phone", user.email as "email" , user.points as "points"  from product_new1.user where user.id_user = %s'
                cursor.execute(sql, (id_user))

                rv = cursor.fetchall()

                if cursor.rowcount > 1:
                    
                    raise self.TooManyObjects
                elif cursor.rowcount == 0:
                   
                    raise self.DoesNotExist
                else:
                    data_json = json.dumps(rv, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict = data
                   
        except:
            self.log.exception("No info about user with id : {id_user} or not exist", extra={'id_user' : id_user})

        return data_dict
    
    def get_receipt(self, id_user):
        self.log.debug('Trying to put receipt data into DB')
        try:
            print(id_user)
            data_dict = {}
            data_d = {}
            with self.connection.cursor() as cursor:
                sql2 ="SELECT * from product_new1.check_value where check_value.id_user = %s"
                cursor.execute(sql2, (str(id_user)))
                rv = cursor.fetchall()
                if cursor.rowcount == 0:
                     raise Exception("no search")
                else:
                    data_json = json.dumps(rv, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict.update({data.get("id_check_value") : data})
                    data_d = {"receipt" :data_dict }    
        except:
            raise Exception("no search")
            self.log.exception('There was a problem while putting receipt to database, check your data')
        return data_d
            



    def set_receipt(self, bar, summ, date, id_user):
        self.log.debug('Trying to put receipt data into DB')
        try:
            with self.connection.cursor() as cursor:
                
                x = bar.split()
                sql1="INSERT INTO product_new1.check_value(id_user, sum, date) values (%s, %s, %s)"   
                cursor.execute(sql1, (id_user,summ, date))
                self.connection.commit()
                sql2 ="SELECT id_check_value from product_new1.check_value where check_value.date = %s"
                cursor.execute(sql2, (date))
                rv = cursor.fetchall()
                if cursor.rowcount > 1:
                    raise self.TooManyObjects
                elif cursor.rowcount == 0:
                    raise self.DoesNotExist
                else:
                    data_json = json.dumps(rv, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict = data
                for line in x:
                    sql = "insert into product_new1.check_product_value (id_check_value, barcode) values (%s,%s)"
                    val = int(line)
                    cursor.execute(sql, (data_dict['id_check_value'],val))
                    self.connection.commit()
        except:
            self.log.exception('There was a problem while putting receipt to database, check your data')
        return "ok"
    
    def set_best(self, name, price, photo):
        self.log.debug('Trying to put best product into DB')
        try:
            with self.connection.cursor() as cursor:
                
            
                sql1="INSERT INTO product_new1.best_product_value(name, price, photo) values (%s, %s, %s)"   
                cursor.execute(sql1, (name, price, photo))
                self.connection.commit()
        except:
            self.log.exception('There was a problem while putting best product to database, check your data')
        return "ok"
        
    def get_best(self, id_best):
        self.log.debug('Trying to get best product from DB')
        try:
            with self.connection.cursor() as cursor:
                sql1="SELECT * FROM product_new1.best_product_value WHERE best_product_value.id_product = %s"   
                cursor.execute(sql1, (id_best))
                self.connection.commit()
        except:
            self.log.exception('There was a problem while getting best product from database, check your data')
        return "ok"
        
    def get_news(self):
        self.log.debug('Trying to get news from DB')
        try:
            data_dict = {}
            data_d = {}
            with self.connection.cursor() as cursor:
                sql1="SELECT * FROM product_new1.news"   
                cursor.execute(sql1)
                rv = cursor.fetchall()
                if cursor.rowcount == 0:
                    raise self.DoesNotExist
                else:
                    data_json = json.dumps(rv, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict.update({data.get("id_news") : data})
                    data_d = {"news" :data_dict }    
        except:
            self.log.exception('There was a problem while putting receipt to database, check your data')
        return data_d   
        
    def delete_best(self, id_best):
        self.log.debug('Trying to DELETE best product from DB')
        try:
            with self.connection.cursor() as cursor:
                sql1="DELETE FROM product_new1.best_product_value WHERE best_product_value.id_product = %s"   
                cursor.execute(sql1, (id_best))
                self.connection.commit()
        except:
            self.log.exception('There was a problem while deleting best product from database, check your data')
        return "ok"
    
    def product_info(self, barcode):
        self.log.debug('Trying to find info about product with barcode: {barcode}', extra={'barcode' : barcode})
        data_dict = {}
        try:

            with self.connection.cursor() as cursor:
                sql = "SELECT  product_features.name as 'feature', product_features_value.value from product_new1.product_features_value, product_new1.product_features, product_new1.product_value where product_features_value.id_feature = product_features.id_feature and product_features_value.id_product = product_value.id_product_value and product_value.bordercode = %s"
                cursor.execute(sql, (barcode))
                rv = cursor.fetchall()
                if cursor.rowcount == 0:
                  
                    raise self.DoesNotExist
                else:
                    
                    data_json = json.dumps(rv, ensure_ascii=False, separators=(',', ': '))
                    data_json = json.loads(data_json, encoding='UTF-8')
                    for data in data_json:
                        data_dict.update({data.get("feature") : data.get("value")})
        except:
            self.log.exception('Product {barcode} wasn`t find or there is no info about it', extra={'barcode' : barcode})
        return data_dict

    def checkbarcode_true(self,barcode):
        with self.connection.cursor() as cursor:
            sql0 = "SELECT *  from product_new1.product_value where  bordercode =%s"
            cursor.execute(sql0, (barcode))
            rv = cursor.fetchall()
            if cursor.rowcount == 0:
                raise self.Error
            else: 
                return "ok"

    def delete(self, barcode):
        self.log.debug('Trying to delete product with barcode: {barcode}', extra={'barcode' : barcode})
        try:
            print(barcode)
            with self.connection.cursor() as cursor:
                sql = "Delete from  product_new1.product_value where bordercode = %s"
                cursor.execute(sql, (barcode))
                self.connection.commit()
        except:
            self.log.exception('Product with barcode {barcode} is absent', extra={'barcode' : barcode})
        return "ok"
    
    def edit_products(self,id_product,name,price,id_category,id_subcategory,id_manufacturer, photo, points, delivery_date,quantity):
        self.log.debug('Trying to edit product with id: {id_product}', extra={'id_product' : id_product})
        try:
            with self.connection.cursor() as cursor:
                
                sql = "UPDATE product_new1.product_value SET product_value.name = %s, product_value.price = %s, product_value.id_category = %s,product_value.id_subcategory = %s,product_value.id_manufacturer = %s, product_value.photo = %s, product_value.points = %s, product_value.delivery_date = %s,product_value.quantity = %s where product_value.id_product_value = %s"

                cursor.execute(sql, (name,price,id_category,id_subcategory,id_manufacturer, photo, points, delivery_date,quantity, id_product))
                self.connection.commit()
        except:
            self.log.exception('Product with id {id_product} is absent', extra={'id_product' : id_product})
        return "ok"

    def edit_features_value(self,value, id_feature, id_product):
        self.log.debug('Trying to edit features value for product with id: {id_product}', extra={'id_product' : id_product})
        try:
            with self.connection.cursor() as cursor:
            
                sql = "UPDATE product_new1.product_features_value SET product_features_value.value = %s where product_features_value.id_product=%s AND product_features_value.id_feature = %s"
                cursor.execute(sql, (value,id_product,id_feature))
                self.connection.commit()

        except:
            self.log.exception('There was an error while editing')
        return "added"

    def close(self):
        try:
            self.log.debug("Trying to close conection -> {host}:{port}/{db}" , extra=self._mysql_con)
            self.connection.close()
            self.log.debug("Successfully closed conection -> {host}:{port}/{db}" , extra=self._mysql_con)

        except:
            self.log.exception("Error with clossing conection {host}:{port}/{db}" , extra=self._mysql_con)

    
def main():
    try:
        con = MySqlCon.get_instance()
        #print(con.search_user("re@gmail.com", "secret1"))
        #print(con.search_user_bool("276920834954"))
        #print(con.search_barcode('644832819197'))
        #print(con.search_barcode_moreinfo('644832819197'))
        #print(con.product_info('733749933993'))
        #print(con.search_admin(barcode = "855555555555", password = "secret1"))
        #print(con.relative_subcategory("одежда"))
        #print(con.manufacturer_list("одежда"))
        #print(con.add_row_to_products('ddddd','838388338389',40.0,10,14, '11.03.2020', 20))
        #print(con.add_features_value('0','1','838388338382'))
        #print(con.listProduct('0','10'))
        #con.edit_features_value()
        #con.delete('5645')
        #print(con.get_receipt('644832819197 438233939273 437628788237', 5000, '15.05.2020 13:07:23'))
        #print(con.write_token("re@gmail.com", "secret1","1234567"))
        #print(con.get_receipt("1"))
        #print(con.user_info(3))
        print(con.get_news())
        
    except Exception:

        self.log.exception('Error connect to Mysql')
        pass







if __name__ == "__main__":

    log_directory = 'log'
    if not os.path.exists(log_directory):
        os.makedirs(log_directory)

    log=logg.setup_logging('MysqlCon')


    main()



