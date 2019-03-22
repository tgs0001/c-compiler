bison -d -y 1405061.y
echo '1'
g++ -w -c -o y.o y.tab.c
echo '2'
flex 1405061.l
echo '3'
g++ -fpermissive -w -c -o l.o lex.yy.c
echo '4'
g++ -o a.out y.o l.o -lfl -ly
echo '5'
./a.out input.c
