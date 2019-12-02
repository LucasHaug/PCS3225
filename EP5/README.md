# EP3-PCS3225

EP3 de SD2.

### Modelo de memória
O PoliLEG possui dois alinhamentos de memória: o de instruções (IM) e o de dados (DM). As memórias possuem palavras sempre de 8bits, mas só se pode ler instruções de 32 em 32 bits, e dados de 64 em 64 bits. Note que o ARM real não possui alinhamento para a memória de dados.

O alinhamento impõe uma restrição no acesso a ambas memórias. Quando acessa-se uma instrução, devido ao alinhamento, os dois bits menos significativos do endereço são ignorados! Isso acontece pois a memória precisa de 4 palavras de 8bits para formar uma palavra de 32bits. Dessa forma, quando acessa-se a posição 0x0 da memória de instruções (IM), a memória sempre retornará uma palavra de 32 bits formada pelas palavras 0x0, 0x1, 0x2 e 0x3. Essas quatro palavras de 8bits formam a instrução de 32bits esperada pelo processador, sendo que os bits menos significativos da instrução estão na posição 0x0 e os mais significativos na posição 0x3. A próxima instrução começa na posição de memória 0x4, a seguinte na 0x8, depois 0xC e assim por diante. Note que todos os endereços do PoliLEG sempre terminam em 00 (os bits "ignorados"pelo processador). Se o seu processador tentar um acesso de memória que não termina em 00, tem algo errado!

Exemplo
Memória:

0x3 ...
0x4 11100010
0x5 10000011
0x6 01000000
0x7 11111000
0x8 ...

Ao acessar a posição 0x4, a memória retornará a palavra: 11111000 01000000 10000011 11100010. Esta é a segunda instrução do MDC, correspondente ao LDUR.

O mesmo acontece com a memória de dados (DM), mas neste caso o alinhamento é de 64bits, então os 3bits menos significativos do endereço serão desconsiderados pois precisamos de 8 palavras de 8bits para formar uma palavra de 64bits. Nessa memória, para acessarmos a primeira palavra de 64bits, usamos o endereço 0x0, mas a segunda está no endereço 0x8! A seguinte estará na posição 0x10, depois 0x18 e assim por diante.

O alinhamento está tão enraizado no PoliLEG, que algumas instruções nem mesmo guardam os últimos bits. É o caso do CBZ e do B, por exemplo. No campo de endereços, o endereço de salto é relativo ao PC atual, então o conteúdo do campo de endereço dessas instruções nem possui os dois últimos bits pois eles sempre são zero! Quando for somar o salto ao PC, o componente shiftLeft fará o trabalho de colocar os dois zeros faltantes (veja o diagrama no enunciado). Isso foi feito pelos projetistas do ARM pois se armazenássemos a quantidade de endereços a saltar completa na instrução, os dois últimos bits sempre seriam zero, desperdiçando espaço e limitando o espaço de salto. A idéia então é armazenar somente a parte importante. E.g. se deseja saltar uma instrução ara frente, o campo de salto da instrução será 0x1 pois o shiftLeft preencherá os bits restantes e somará na verdade 0x4 ao PC, ficando PC+0x4, que é o endereço da próxima instrução (não faz muito sentido saltar para a próxima instrução, foi só um exemplo). 

Fonte: Moodle da disciplina.
