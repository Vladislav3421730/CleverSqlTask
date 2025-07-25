# Тестовое задание на позицию Junior Database Migration Expert
Задание представляет собой миграцию скрипта с Oracle на PostgreSQL

## Запуск скрипта
Чтобы скрипт можно было запустить, перейдите в корневую папку проекта
```bash
cd CleverSqlTask
```
Затем запустите команду Docker
```bash
docker compose up
```
После этого запустите контейнер postgres в интерактивном режиме 
```bash
docker exec -it postgres sh
```
После этого нужно войти в нужную БД
```bash
psql -U admin -d task
```
Далее можно вставить скрипт из файла script.sql и посмотреть как работают процедуры и функции
## Архитектурные решения

### Особенности миграции с Oracle на PostgreSQL

В Oracle активно используются пакеты (packages), которые позволяют объединять связанные процедуры, функции, переменные и типы данных в единую структуру. Однако в стандартном PostgreSQL (community edition) такой функциональности нет — пакеты поддерживаются только в Postgres Pro Enterprise (начиная с версии 15), что ограничивает переносимость и усложняет отладку в обычных средах.

**В связи с этим, при миграции я принял следующие решения:**

- **Пакеты**:  
  Вместо пакетов Oracle, вся логика была реализована через отдельные процедуры и функции в одной схеме. Для группировки логики использовались префиксы и единый набор объектов.

- **Пользовательские типы**:  
  Типы данных, определённые в Oracle через `CREATE TYPE ... AS OBJECT`, были перенесены как composite types PostgreSQL с помощью `CREATE TYPE ... AS (...)`.

- **Коллекции (TABLE OF ...)**:  
  В Oracle коллекции часто используются для хранения временных наборов объектов в памяти. В PostgreSQL для этого была создана временная таблица (`CREATE TEMP TABLE`), которая имитирует поведение коллекции на время сессии.

- **Процедуры и функции**:  
  Все процедуры и функции из пакета Oracle были реализованы как отдельные объекты в PostgreSQL с сохранением их логики.  
  - Процедура `hire` добавляет сотрудника во временную таблицу и вызывает логирование.
  - Процедура `log` переносит новые записи из временной таблицы в таблицу логов, избегая дублирования.
  - Функция `getlist` возвращает список сотрудников в виде набора строк пользовательского типа, а также выводит информацию через `RAISE NOTICE` (аналог `DBMS_OUTPUT.PUT_LINE`).

- **Инициализация данных**:  
  В Oracle пакеты могут содержать блок инициализации, который выполняется при первом обращении к пакету. В PostgreSQL для инициализации данных был использован анонимный блок `DO $$ ... $$`, который добавляет тестовые данные и вызывает необходимые процедуры.

- **Системные функции и синтаксис**:  
  - `SYSDATE` заменён на `CURRENT_DATE`.
  - `MERGE INTO ... WHEN NOT MATCHED THEN INSERT` реализован через `INSERT ... WHERE NOT EXISTS`.

### Почему не использовались пакеты

Пакеты в PostgreSQL доступны только в коммерческой версии Postgres Pro Enterprise. Для обеспечения совместимости и простоты запуска в любой среде (в том числе через Docker) было принято решение реализовать логику без использования пакетов, чтобы скрипт работал в стандартном PostgreSQL.

---

**Таким образом, вся бизнес-логика из Oracle была перенесена в PostgreSQL с сохранением структуры и поведения, но с учётом особенностей и ограничений выбранной СУБД.**
