import sys
import jinja2
from jinja2 import Template
import os
from os import getenv
import logg

# Import the email modules
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
from email.header import Header
from email.utils import formataddr
from smtplib import SMTP
from typing import Dict




SMTP_HOST='smtp.gmail.com'
SMTP_PORT=587
SMTP_SENDER = "pjoidrivedisk@gmail.com"
SMTP_PASSWORD = "password"


class EmailSender():

    def __init__(self,email, code) -> None:

        self.email = email
        self.code = code
        self.recepient = "<{{ email }}>"
        self.subject ="Your scanpay code "
        self.body = "template.j2"
        self.log = logg.get_class_log(self)
        self.result = {"email" : self.email, "code": self.code}
        try:
            self.recepient = self.recepient_template(self.recepient,**self.result)
            self.subject = self.subject_template(self.subject,**self.result)
        except Exception as e:
            self.log.exception('Error with templete for recipient and subject: {error}',extra = {'error' : e.args})
            raise    



        html = self.render_template(self.body, **self.result)
        
        # send email to a list of email addresses
        self.send_email(html)


    def subject_template(self, template, **kwargs):
        template = Template(template)
        return template.render(kwargs)

    def recepient_template(self, template,**kwargs):
         template = Template(template)
         return template.render(kwargs)


    def render_template(self, template, **kwargs):

        templateLoader = jinja2.FileSystemLoader(searchpath="./template/")
        templateEnv = jinja2.Environment(loader=templateLoader)
        templ = templateEnv.get_template(template)
        templ = templ.render(kwargs)

        return templ

    def send_email(self ,body=None):
        
        msg = MIMEMultipart('related')
        try:
            if SMTP_SENDER:  
                msg['From'] = SMTP_SENDER
            else: raise ValueError('the field "From" is empty ')    
            msg['Subject'] = self.subject   
            msg['To'] =self.recepient    
        except ValueError as e:
            self.log.exception('Error : {error}',extra = {'error' : e.args})
            raise
        except Exception as e:
            self.log.exception('Error with add attributes email : {error}',extra = {'error' : e})
            raise    

        try:
            msg.attach(MIMEText(body, 'html'))
        except Exception as e:
            self.log.exception('Error with add body')
            raise

        try:
            server = SMTP(SMTP_HOST, SMTP_PORT)
            server.starttls()
            server.login(SMTP_SENDER, SMTP_PASSWORD)
        except Exception as e:
            self.log.exception('Error with config SMTP_HOST, SMTP_PORT')
            raise


        try:
            self.log.info('sending email to {full_name} , subject - {subject} ', extra={'full_name': self.recepient , "subject" : self.subject} )
            server.sendmail(SMTP_SENDER, self.recepient, msg.as_string())
            self.log.info('email sent successfully to {full_name}', extra={'full_name': self.recepient})
        except Exception as e:
            self.log.exception('Error sending email')
            raise
        finally:
            server.quit()


