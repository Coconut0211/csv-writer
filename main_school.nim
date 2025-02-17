import os  # папки, файлы, аргументы командной строки
import sequtils, strutils, strformat  # работа со строками
import random  # для генерации случайных чисел

randomize()  # Для рандомизации генератора

type
  Subjects* = enum
    NONE, История, География, Математика, Биология
  Person* = ref object of RootObj
    firstname*: string
    lastname*: string
    birthDate*: int64
  Director* = ref object of Person
  Teacher* = ref object of Person
    subject*: Subjects
  Student* = ref object of Person
    classNum*: int
    classLet*: char
  School* = ref object of RootObj
    director*: Director
    students*: seq[Student]
    teachers*: seq[Teacher]

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
  return names[rand(0..names.len - 1)]


proc genCSV(
    header: string = "",
    rows: seq[seq[string]] = @[@[""]],
    csvFileName: string = "default.csv"
  ) =
  var file: File = open(csvFileName,fmWrite)
  file.writeLine(header)
  for item in rows:
    file.writeLine(join(item.mapIt(join(@[""""""",it,"""""""])),","))
  file.close()
  ## Вносит заголовок и строки в csvFileName
  ## если значения не переданы, то должны использоваться значения по умолчанию

proc genDirector(csvFileName: string, rowsCount: int) =
  var rows: seq[seq[string]]
  for i in 1 .. rowsCount:
    rows.add(@[randName(),getData("src" / "last_names.txt")[rand(0..999)],genRandDate()])
  genCSV("firstName,lastName,birthDate",rows,csvFileName)

proc genTeachers(csvFileName: string, rowsCount: int) =
  var rows: seq[seq[string]]
  for i in 1 .. rowsCount:
    rows.add(@[randName(),getData("src" / "last_names.txt")[rand(0..999)],genRandDate(),$Subjects.toSeq()[1 .. ^1][rand(0..3)]])
  genCSV("firstName,lastName,birthDate,subject",rows,csvFileName) 

proc genStudents(csvFileName: string, rowsCount: int) =
  let letters = @["A","B","C","D","E","F","G"]
  var rows: seq[seq[string]]
  for i in 1 .. rowsCount:
    rows.add(@[randName(),getData("src" / "last_names.txt")[rand(0..999)],genRandDate(1..28,1..12,2005..2018),$rand(1..11),letters[rand(0..6)]])
  genCSV("firstName,lastName,birthDate,classNum,classLet",rows,csvFileName) 

when isMainModule:
  var rowsCount = 0  # Сколько строк писать
  if paramCount() > 0:  # Если передан аргумент командной строки
    rowsCount = paramStr(1).parseInt  # Присваиваем новое значение
  else:
    stderr.writeLine("Nothing to write. Quit")  # Ошибка
    quit()  # Завершаем работу
  genDirector(  
    getAppDir() / "data" / "school_direcor.csv",
    1
  )
  genTeachers(  
    getAppDir() / "data" / "school_teachers.csv",
    rowsCount div 10
  )
  genStudents(  
    getAppDir() / "data" / "school_students.csv",
    rowsCount
  )
           