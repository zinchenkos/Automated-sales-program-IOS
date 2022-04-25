import os
import logg
import json
from redisCon import RedisCon
from datetime import datetime, timedelta
from mysqlCon import MySqlCon
from email_sender import EmailSender
import sys
import random



from aiohttp import web
import jwt


JWT_SECRET = 'secret'
JWT_ALGORITHM = 'HS256'
JWT_EXP_DELTA_SECONDS = 2592000


log = None
redis_con = None




def json_response(body='', **kwargs):
    log.debug("start make json_response woth body: {body}",extra={'body' : body}) 
    kwargs['body'] = json.dumps(body or kwargs['body'], ensure_ascii=False)
    kwargs['content_type'] = 'application/json'
    log.debug("Starting to send son_response with datkwargsa -> {kwargs}", extra = {"kwargs": kwargs})
    return web.Response(**kwargs)

async def test(request):
    try:
        item =  MySqlCon.get_instance().search_barcode("644832819197")
    except Exception:
        log.exception('POST get_user request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    data_json = json.dumps(item)
    return json_response(item)    



async def login(request):
    post_data = await request.post()
    log.debug("POST-login request with post_data -> {post}", extra = {"post": post_data})

    try:
        user = MySqlCon.get_instance().search_user(post_data['email'],post_data['password'])
        payload = {
        'user_id': user['id_user'],
        'barcode': user["bordercode"],
        'exp': datetime.utcnow() + timedelta(seconds=JWT_EXP_DELTA_SECONDS)
        }

        jwt_token = jwt.encode(payload, JWT_SECRET, JWT_ALGORITHM)
        MySqlCon.get_instance().write_token(post_data['email'],post_data['password'],jwt_token.decode('utf-8'))
    except Exception:
        log.exception('POST-login request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'},status = 400)
    return json_response({'status': 'ok', 'message': jwt_token.decode('utf-8')})
    
async def entering(request):
    post_data = await request.post()
    log.debug("POST-entering request with post_data -> {post}", extra = {"post": post_data})
    try:
 
        admin = MySqlCon.get_instance().search_admin(post_data['barcode'],post_data['password']) 
    except Exception:
        log.exception('POST-entering request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'},status = 400)
    return json_response({'status': '200', 'message': 'Enter successful'})


async def get_user(request):
    post_data = await request.post()
    print(post_data)
    log.debug("POST get_user request with post_data -> {post}", extra = {"post": post_data})
    try:
        item = MySqlCon.get_instance().search_barcode(post_data['barcode'])
    except Exception:
        log.exception('POST get_user request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    data_json = json.dumps(item)
    return json_response(item)

async def get_news(request):
    try:
        item = MySqlCon.get_instance().get_news()
    except Exception:
        log.exception('GET get_news request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    data_json = json.dumps(item)
    return json_response(item)  

async def get_receipt(request):
    print(request.user)
    if request.user:
        log.debug("GET get_user_moreinfo request ")
        try:
            item = MySqlCon.get_instance().get_receipt(request.user)
            print 
        except Exception:
            log.exception('POST get_user_moreinfo request wasn`t done')
            return json_response({'status': '400', 'message': 'Wrong credentials'}, status=225)
        data_json = json.dumps(item)
        return json_response(item)
    else: return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)    


async def get_user_moreinfo(request):
    post_data = await request.post()
    log.debug("POST get_user_moreinfo request with post_data -> {post}", extra = {"post": post_data})
    try:
        item = MySqlCon.get_instance().search_barcode_moreinfo(post_data['barcode'])
    except Exception:
        log.exception('POST get_user_moreinfo request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    data_json = json.dumps(item)
    return json_response(item)
 
async def user_info(request):
    
    if(request.user):
        try:
            item = MySqlCon.get_instance().user_info(request.user)
        except Exception:
            log.exception('GET user_info request wasn`t done')
            return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
        data_json = json.dumps(item)
        return json_response(item)
    else: return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400) 

async def ser_receipt(request):
    post_data = await request.post()

    if(request.user):

        log.debug("POST-receipt request with post_data -> {post}", extra = {"post": post_data})
        try:
            MySqlCon.get_instance().set_receipt(post_data['barcode'],post_data['sum'],post_data['date'],request.user)
        except Exception:
            log.exception('POST-receipt request wasn`t done')
            return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
        return json_response({'status' : 'ok', 'message': 'Receipt was saved'}, status=200)
    else: return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400) 


async def new_account(request):
    post_data = await request.post()
    log.debug("POST new_account request with post_data -> {post}", extra = {"post": post_data})
    try:
        code = post_data['code']
        email = post_data['email']
        print(post_data['name'],post_data['phone'],email,post_data['password'],email)
        if RedisCon.get_instance().searchCode(email,code):
            password = post_data['password']
            MySqlCon.get_instance().add_row_to_user(random.randint(2345600000000, 2345700000000), post_data['name'],post_data['phone'],email,post_data['password'])
            user = MySqlCon.get_instance().search_user(post_data['email'],post_data['password'])
            print(user)
            payload = {
            'user_id': user['id_user'],
            'barcode': user["bordercode"],
            'exp': datetime.utcnow() + timedelta(seconds=JWT_EXP_DELTA_SECONDS)
            }

            jwt_token = jwt.encode(payload, JWT_SECRET, JWT_ALGORITHM)
            MySqlCon.get_instance().write_token(post_data['email'],post_data['password'],jwt_token.decode('utf-8'))
        else: return json_response({'status': '420', 'message': 'Wrong code'}, status=420)
    except Exception:
        log.exception('POST get_info request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response({'status': 'ok', 'message': jwt_token.decode('utf-8')})


async def check_email(request):
    post_data = await request.post()
    log.debug("POST check_email request with post_data -> {post}", extra = {"post": post_data})
    try:
        email = post_data['email']
        MySqlCon.get_instance().check_email(email)
        #EmailSender(post_data['email'], Emairandom.randint(2345600000000, 2345700000000))
        code = random.randint(1000, 9999)
        EmailSender(email, code)
        RedisCon.get_instance().setCode(email, code)
    except Exception:
        log.exception('POST get_info request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response({'status' : 'ok', 'message': 'Receipt was saved'}, status=200)


async def get_info(request):
    post_data = await request.post()
    log.debug("POST get_info request with post_data -> {post}", extra = {"post": post_data})
    try:
        item = MySqlCon.get_instance().product_info(post_data['barcode'])
    except Exception:
        log.exception('POST get_info request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response(item)
  
async def get_best(request):
    post_data = await request.post()
    log.debug("POST get_best request with post_data -> {post}", extra = {"post": post_data})
    try:
        item = MySqlCon.get_instance().get_best(post_data['id_best'])
    except Exception:
        log.exception('POST get_best request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    data_json = json.dumps(item)
    print(data_json)
    return json_response(item)

async def subcategory(request):
    post_data = await request.post()
    log.debug("POST-subcategory request with post_data -> {post}", extra = {"post": post_data})
    try:
        item = MySqlCon.get_instance().relative_subcategory(post_data['category'])
    except Exception:
        log.exception('POST-subcategory request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    data_json = json.dumps(item)
    
    return json_response(item)

async def manufacturer(request):
    post_data = await request.post()
    log.debug("POST-manufacturer request with post_data -> {post}", extra = {"post": post_data})
    try:
        item = MySqlCon.get_instance().manufacturer_list(post_data['category'])
    except Exception:
        log.exception('POST-manufacturer request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response(item)

async def checkbarcode(request):
    post_data = await request.post()
    log.debug("POST-checkbarcode request with post_data -> {post}", extra = {"post": post_data})
    try:
        MySqlCon.get_instance().checkbarcode(post_data['barcode'])
    except Exception:
        log.exception('POST-checkbarcode request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response({'status' : 'ok', 'message': 'Barcode is new'}, status=200)
    
async def checktoken(request):
    post_data = await request.post()
    log.debug("POST-checktoken request with post_data -> {post}", extra = {"post": post_data})
    try:
        MySqlCon.get_instance().checktoken(post_data['token'])
    except Exception:
        log.exception('POST-checktoken request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response({'status' : 'ok', 'message': 'Token exists'}, status=200)

'''async def checkbarcode_true(request):
    post_data = await request.post()
    try:
        MySqlCon.get_instance().checkbarcode_true(post_data['barcode'])
    except Exception:
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response({'status' : 'ok', 'message': 'Barcode is new'}, status=200)'''

async def add(request):
    post_data = await request.post()
    log.debug("POST-add request with post_data -> {post}", extra = {"post": post_data})
    try:
        MySqlCon.get_instance().add_row_to_products(post_data['name'],post_data['barcode'],post_data['price'],post_data['id_subcategory'],post_data['id_manufacturer'], post_data['delivery_date'], post_data['quantity'])
    except Exception:
        log.exception('POST-add request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response({'status' : 'ok', 'message': 'Added'}, status=200)

async def edit(request):
    post_data = await request.post()
    log.debug("POST-edit request with post_data -> {post}", extra = {"post": post_data})
    try:
        MySqlCon.get_instance().edit_products(post_data['id_product'],post_data['name'],post_data['price'],post_data['id_category'],post_data['id_subcategory'],post_data['id_manufacturer'], post_data['photo'], post_data['points'],post_data['delivery_date'], post_data['quantity'])
    except Exception:
        log.exception('POST-edit request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response({'status' : 'ok', 'message': 'Added'}, status=200)

async def add_features(request):
    post_data = await request.post()
    log.debug("POST-add_features request with post_data -> {post}", extra = {"post": post_data})
    try:
        MySqlCon.get_instance().add_features_value(post_data['value'], post_data['id_feature'],post_data['barcode'])
    except Exception:
        log.exception('POST-add_features request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response({'status' : 'ok', 'message': 'Added'}, status=200)

async def edit_features(request):
    post_data = await request.post()
    log.debug("POST-edit_features request with post_data -> {post}", extra = {"post": post_data})
    try:
        MySqlCon.get_instance().edit_features_value(post_data['value'], post_data['id_feature'],post_data['id_product'])
    except Exception:
        log.exception('POST-edit_features request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response({'status' : 'ok', 'message': 'Added'}, status=200)
    
async def delete(request):
    post_data = await request.post()
    log.debug("POST-delete request with post_data -> {post}", extra = {"post": post_data})
    try:
        MySqlCon.get_instance().delete(post_data['barcode'])
    except Exception:
        log.exception('POST-delete request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response({'status' : 'ok', 'message': 'Deleted'}, status=200)


async def get_rowcount(request):
    log.debug("POST-get_rowcount request")
    try:
        row = MySqlCon.get_instance().rowcount()
    except Exception:
        log.exception('POST-get_rowcount request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response(row)

async def listProductlimit(request):
    post_data = await request.post()
    log.debug("POST-listProductlimit request with post_data -> {post}", extra = {"post": post_data})
    try:
        item = MySqlCon.get_instance().listProduct(post_data['startLimit'],post_data['limit'])
     
    except Exception:
        log.exception('POST-listProductlimit request wasn`t done')
        return json_response({'status': '400', 'message': 'Wrong credentials'}, status=400)
    return json_response(item)


#async def 


async def auth_middleware(app, handler):
    async def middleware(request):
        request.user = None

        jwt_token = request.headers.get('authorization', None)

        request.user = None
        
        if jwt_token:
            try:
                print(jwt_token)
                print("jwt_token")

                payload = jwt.decode(jwt_token, JWT_SECRET,
                                     algorithms=[JWT_ALGORITHM])
                print(payload)
            

                if(not RedisCon.get_instance().searchTocken(jwt_token)):

                    MySqlCon.get_instance().checktoken(jwt_token)

                    RedisCon.get_instance().setData(payload['user_id'], jwt_token, 216000)


            except Exception as e:
                print(e)
                return json_response({'status' : 'error', 'message': 'Token is invalid'},
                                     status=401)

            request.user=payload["user_id"]  
            print(request.user)  
        return await handler(request)

    return middleware

if __name__ == "__main__":

    
    log_directory = 'log'
    log = logg.setup_logging('Server')
    log = logg.get_log("Web-server")

  
    try:
        con = MySqlCon.get_instance()

    except Exception as e :
        log.exception('Error connect Mysql , Error -> {error}', extra = {"error" : e})
        MySqlCon.get_instance().close()
        sys.exit(1)
    try:
        redis_con = RedisCon.get_instance()
    except Exception as e:
         log.exception('Error connect redis , Error -> {error}', extra = {"error" : e})   

    try:
        app = web.Application(middlewares=[auth_middleware])
        app.router.add_route('POST', '/barcode', get_user)
        app.router.add_route('POST', '/barcodeall',get_user_moreinfo)
        app.router.add_route('POST', '/login', login)
        app.router.add_route('POST', '/info', get_info)
        #app.router.add_route('GET', '/barcodeall', get_user_moreinfo)
        app.router.add_route('POST', '/entering', entering)
        app.router.add_route('POST', '/listProductlimit', listProductlimit)
        app.router.add_route('POST', '/category', subcategory)
        app.router.add_route('POST', '/manufacturer', manufacturer)
        app.router.add_route('POST', '/add', add)
        app.router.add_route('POST', '/add_features', add_features)
        app.router.add_route('POST', '/checkbarcode', checkbarcode)
        app.router.add_route('POST', '/checktoken', checktoken)
        app.router.add_route('GET', '/rowcount', get_rowcount)
        app.router.add_route('POST', '/edit', edit)
        app.router.add_route('POST', '/delete', delete)
        app.router.add_route('POST', '/edit_features', edit_features)
        app.router.add_route('POST', '/setreceipt', ser_receipt)
        app.router.add_route('POST', '/get_best', get_best)
        app.router.add_route('POST', '/add_account', new_account)
        app.router.add_route('POST', '/check_email', check_email)
        app.router.add_route('GET', '/receipt', get_receipt)
        #app.router.add_route('POST', '/checkbarcode_true', checkbarcode_true)
        app.router.add_route('GET', '/user_info', user_info)
        app.router.add_route('GET', '/test', test)
        app.router.add_route('GET', '/get_news', get_news)

        web.run_app(app, port=3000)
    except Exception as e :
        log.exception('Error start web server , Error -> {error}', extra = {"error" : e})
        sys.exit(1)
            




