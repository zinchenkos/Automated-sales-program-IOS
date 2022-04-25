
![ScanPay](Img1.png)


With ScanPay you can buy product in couple of steps, you just need to scan a barcode of product, find it in your app and then pay. In this version, a scanner, a server part and an IOS App interface were implemented (there is also version with goods accounting on Java, check my repository "Automated-sales-program"). Payment system wasn't conneted. Server is based on aiohttp lib.

___
## Functionality:

- Response to user requests:  
```
        - registration 
        - authorization
        - barcode request
        - edit item on database
        - delete item on database
        - add new item to database
```
- Unique token generation
- Working with database: 
```
        - conect 
        - requests to database
        - read response from database
```        
- Send email at registation 

---
## Start with python 
```
start python file 
```
```
python3 -m web.py 

```


---

##  Start with docker (or docker-compose)

Dockerfile  based  on image python:3-slim or python:3-alpine










