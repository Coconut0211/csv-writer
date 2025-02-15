import os  # папки, файлы, аргументы командной строки
import sequtils, strutils, strformat  # работа со строками
import random  # для генерации случайных чисел

randomize()  # Для рандомизации генератора

type
  Post* = enum
    NONE, Кассир, Уборщик, Консультант, Менеджер, Директор

  Staff* = ref object of RootObj
    firstName*: string
    lastName*: string
    birthDate*: int64
    post*: Post

  Good* = ref object of RootObj
    title*: string
    price*: float
    endDate*: int64
    discount*: float
    count*: int

  Cash* = ref object of RootObj
    number*: int
    free*: bool
    totalCash*: float

  Shop* = ref object of RootObj
    staff*: seq[Staff]
    goods*: seq[Good]
    cashes*: seq[Cash]

proc getData(fileName: string): seq[string] =
  ## Получает все не пустные строки из файла
  let file = open(fileName)
  result = file.readAll.splitLines.filterIt(it != "")
  file.close()

proc genRandDate(
    d: HSlice = 1..28,
    m: HSlice = 1..12,
    y: HSlice = 1970..2000
  ): string =
  ## Возвращает строку даты на основе переданного диапазона значений
  ## По умолчанию, день: от 1 до 28
  ## месяц: от 1 до 12
  ## год: с 1970 по 2000
  ## Учтите, что для срока годности как минимум год должен быть другим.
  fmt"{rand(d):02}.{rand(m):02}.{rand(y)}"

proc randName(): string =
  var names = getData("src" / "female_names.txt")
  names.insert(getData("src" / "male_names.txt"))
  return names[rand(0..names.len)]


proc genCSV(
    header: string = "",
    rows: seq[seq[string]] = @[@[""]],
    csvFileName: string = "default.csv"
  ) =
  var file: File = open(csvFileName,fmWrite)
  file.writeLine(header)
  for item in rows:
    file.writeLine(join(item,","))
  file.close()
  ## Вносит заголовок и строки в csvFileName
  ## если значения не переданы, то должны использоваться значения по умолчанию

proc genStaff(csvFileName: string, rowsCount: int) =
  ## Функция генерации сотрудников
  let posts = @["Кассир", "Уборщик", "Консультант", "Менеджер", "Директор"]
  var rows: seq[seq[string]]
  for i in 1 .. rowsCount:
    rows.add(@[randName(),getData("src" / "last_names.txt")[rand(0..999)],genRandDate(),posts[rand(0..4)]])
  genCSV("firstName,lastName,birthDate,post",rows,csvFileName)

proc genGoods(csvFileName: string, rowsCount: int) =
  ## Функция генерации товаров
  var rows: seq[seq[string]]
  for i in 1 .. rowsCount:
    rows.add(@[getData("src" / "good_titles.txt")[rand(0..99)],$rand(1..500),genRandDate(1..28,1..12,2024..2025),$rand(0..100),$rand(0..1000)])
  genCSV("title,price,endDate,discount,count",rows,csvFileName) 

proc genCashes(csvFileName: string, rowsCount: int) =
  ## Функция генерации касс
  var rows: seq[seq[string]]
  for i in 1 .. rowsCount:
    rows.add(@[$rand(1..10),$rand(0..1),$rand(1..5000)])
  genCSV("number,free,totalCash",rows,csvFileName) 

when isMainModule:
  var rowsCount = 0  # Сколько строк писать
  if paramCount() > 0:  # Если передан аргумент командной строки
    rowsCount = paramStr(1).parseInt  # Присваиваем новое значение
  else:
    stderr.writeLine("Nothing to write. Quit")  # Ошибка
    quit()  # Завершаем работу
  genStaff(  # Генерируем сотрудников
    getAppDir() / "data" / "shop_staff.csv",
    rowsCount
  )
  genGoods(  # Генерируем товары
    getAppDir() / "data" / "shop_goods.csv",
    rowsCount * 10  # в 10 раз больше
  )
  genCashes(  # Генерируем кассы
    getAppDir() / "data" / "shop_cashes.csv",
    rowsCount div 10  # в 10 раз меньше
  )
           