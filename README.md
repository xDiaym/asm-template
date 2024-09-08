# uasm

Шаблон для лаборатрных работ по ассемблеру для кафедры К3 МФ МГТУ им Н.Э.Баумана

> [!WARNING]
> Работоспособность под Windows не гарантируется

## Начало работы

1. Склонируйте репозиторий и поменяйте название
    1. Сделайте это самостоятельно, через `git clone git@github.com:xDiaym/asm-template.git` и 
`find . -not -path ".git/*" -not -path './build_*' -type f | xargs sed -i 's/lab1/<PROJECT_NAME>/g`
    2. Воспользуйтесь скриптом `bash <(curl -Ls https://raw.githubusercontent.com/xDiaym/asm-template/master/install.sh) <PROJECT_NAME>`
    3. Используйте этот репозиторий как шаблон в GitHub 
2. Установите пакеты `make`, `cmake`, `nasm`, `python3` и компилятор C++.
  Если Вы хотите использовать форматтеры, то установите `black` и `clang-format`
3. Отредактируйте файлы [func.asm](./src/func.asm) и [config.py](./vissuite/config.py) в соответствии с заданием
4. Запустите проект через `make run-release`

## Команды

* `make build-debug` - сборка проекта в режиме отладки
* `make build-release` - сборка проекта в релизном режиме
* `make run-debug` - запуск проекта в интерактивном режиме для отладки
* `make run-release` - сборка проекта в релизном режиме
* `make format` - запуск форматтеров
* `make dist-clean` - отчистка временных файлов

## Vissuite

Для визуализации используется мини-фреймворк vissuite. На вход он принимает путь до исполняемого файла с лабораторной работой, запускает ее, читает данные и строит графики. Функция для эталонного графика берется из файла [config.py](./vissuite/config.py).

## Полезные ссылки

* https://www.laruence.com/sse/# - Список intrinsics от Intel 
* https://en.wikibooks.org/wiki/X86_Assembly/Floating_Point - гайд по x87 FPU
