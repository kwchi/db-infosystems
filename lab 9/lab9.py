import redis

r = redis.Redis()

#Додавання події до потоку
r.xadd('mystream', {'sensor-id': '1234', 'temperature': '19.8'})

#Читання подій
messages = r.xrange('mystream')
print(messages)
