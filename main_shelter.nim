import os  # папки, файлы, аргументы командной строки
import sequtils, strutils, strformat  # работа со строками
import random  # для генерации случайных чисел

randomize()  # Для рандомизации генератора

type
  Role* = enum
    NONE, Директор, Бухгалтер, Ветеринар
  Post* = object
    dol*: Role
    glavn*: bool
  Person* = ref object of RootObj
    firstname*: string
    lastname*: string
    birthDate*: int64
  Manager* = ref object of Person
    post*: Post
  Staff* = ref object of Person
    uid*: int
  Pet* = ref object of RootObj
    name*: string
    age*: int 
  Shelter* = ref object of RootObj
    staff*: seq[Staff]
    pet*: seq[Pet]
    manager*: seq[Manager]

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

proc genManagers(csvFileName: string, rowsCount: int) =
  let roles = Role.toSeq()[1 .. ^1]
  var currentRole: string
  var rows: seq[seq[string]]
  for i in 1 .. rowsCount:
    currentRole  = $roles[rand(0..2)]
    if i < 4:
      currentRole = join(@["Главный ", $roles[i - 1]])
    rows.add(@[randName(),getData("src" / "last_names.txt")[rand(0..999)],genRandDate(),currentRole])
  genCSV("firstName,lastName,birthDate,post",rows,csvFileName)

proc genStaff(csvFileName: string, rowsCount: int) =
  var rows: seq[seq[string]]
  for i in 1 .. rowsCount:
    rows.add(@[randName(),getData("src" / "last_names.txt")[rand(0..999)],genRandDate(),$rand(1..1000)])
  genCSV("firstName,lastName,birthDate,uid",rows,csvFileName) 

proc genPets(csvFileName: string, rowsCount: int) =
  var rows: seq[seq[string]]
  for i in 1 .. rowsCount:
    rows.add(@[getData("src" / "pet_names.txt")[rand(0..999)],$rand(1..20)])
  genCSV("name,age",rows,csvFileName) 

when isMainModule:
  var rowsCount = 0  # Сколько строк писать
  if paramCount() > 0:  # Если передан аргумент командной строки
    rowsCount = paramStr(1).parseInt  # Присваиваем новое значение
  else:
    stderr.writeLine("Nothing to write. Quit")  # Ошибка
    quit()  # Завершаем работу
  genManagers(  
    getAppDir() / "data" / "shelter_managers.csv",
    rowsCount div 10
  )
  genStaff(  
    getAppDir() / "data" / "shelter_staff.csv",
    rowsCount
  )
  genPets(  
    getAppDir() / "data" / "shelter_pets.csv",
    rowsCount * 10
  )
           