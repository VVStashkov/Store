# Анализ запросов

## 1
### без индексов
![img_1.png](image/nonIndexed/img_1.png)
![img_6.png](image/nonIndexed/img_6.png)
### с индексами
#### btree
![img_1-1.png](image/indexed/img_1-1.png)
#### hash
![img_1-2.png](image/indexed/img_1-2.png)
### Вывод
при использовании Like% индексы не используются

## 2
### без индексов
![img_2.png](image/nonIndexed/img_2.png)
![img_7.png](image/nonIndexed/img_7.png)
### с индексами
#### btree
![img_2-1.png](image/indexed/img_2-1.png)
#### hash
![img_2-2.png](image/indexed/img_2-2.png)
### Вывод
hash скан работает медленнее чем btree при использовании интерваьлных условий (<, >)

## 3
### без индексов
![img_3.png](image/nonIndexed/img_3.png)
![img_8.png](image/nonIndexed/img_8.png)
### с индексами
#### btree
![img_3-1.png](image/indexed/img_3-1.png)
#### hash
![img_3-2.png](image/indexed/img_3-2.png)
### Вывод
hash скан работает быстрее чем btree при условии равенства

## 4
### без индексов
![img_4.png](image/nonIndexed/img_4.png)
![img_9.png](image/nonIndexed/img_9.png)
### с индексами
#### btree
![img_4-1.png](image/indexed/img_4-1.png)
#### hash
![img_4-2.png](image/indexed/img_4-2.png)
### Вывод
предполагаемое время было меньше у варианта с hash, однако в реальности время почти не отливается, помимо этого, при существовании обоих индексов, ввыбирался почему-то btree

## 5
### без индексов
![img_5.png](image/nonIndexed/img_5.png)
![img_10.png](image/nonIndexed/img_10.png)
### с индексами
#### btree
![img_5-1.png](image/indexed/img_5-1.png)
#### hash
![img_5-2.png](image/indexed/img_5-2.png)
### Вывод
если с помощью like искать конкретную строку, то индексы работают. При этом hash работает быстрее и выбирается преимущественно, перед btree
