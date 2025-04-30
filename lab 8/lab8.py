import redis

r = redis.Redis(host='localhost', port=6379, decode_responses=True)

#Лічильник
r.incr('mycounter')
print('Лічильник:', r.get('mycounter'))

#Список задач
r.lpush('tasks', 'Task1')
r.lpush('tasks', 'Task2')
print('Задачі:', r.lrange('tasks', 0, -1))

#Публікація повідомлення
r.publish('channel', 'Hello from Python!')
