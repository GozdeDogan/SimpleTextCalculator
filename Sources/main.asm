;*****************************************************************
;* This stationery serves as the framework for a                 *
;* user application (single file, absolute assembly application) *
;* For a more comprehensive program that                         *
;* demonstrates the more advanced functionality of this          *
;* processor, please see the demonstration applications          *
;* located in the examples subdirectory of the                   *
;* Freescale CodeWarrior for the HC12 Program directory          *
;*****************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;                                                                                                                                                                    ;;;
;;;     Gözde DOÐAN - 131044019                                                                                                            ;;;
;;;     Assignment1                                                                                                                                       ;;;
;;;     20 Mart 2013 - 17:00                                                                                                                          ;;;
;;;                                                                                                                                                                    ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



; export symbols
            XDEF Entry, _Startup            ; export 'Entry' symbol
            ABSENTRY Entry        ; for absolute assembly: mark this as application entry point



; Include derivative-specific definitions 
		INCLUDE 'derivative.inc' 

ROMStart    EQU  $4000                                        ; absolute address to place my code/constant data
myStr       EQU  $1500                                            ; firs adress of input string
iter    EQU  $1520                                                    ; string üzerinde dolaþmak icin 
count     EQU  $1522                                               ; count
space       EQU  $0020                                            ; space ' ' ascii
dot           EQU $002E                                              ; ' . '  ascii
equal      EQU $003D                                              ; ' = ' ascii
item1_1       EQU  $1530                                        ; item1_1  ilk sayinin tam kismi - noktadan oncesi
item1_2       EQU $1540                                         ; item1_2 ilk sayinin double kismi - noktadan sonrasi
item2_1       EQU  $1550                                        ; item2_1 ikinci sayinin tam kismi - noktadan oncesi
item2_2       EQU $1560                                         ; item2_2 ikinci sayinin tam kismi - noktadan sonrasi
temp        EQU  $1524  
tempo       EQU  $1526
plus         EQU  $1570                                             ;  ' + '
minus         EQU  $1571                                         ;  ' - '
result   EQU  $1600                                                 ; islem sonucunun yazilacagi adres
tempRes     EQU  $15F8                                        ; carry olmadan sonuc;15f8-15fd  
tempCount   EQU  $15F0
tempTRES    EQU  $15F2
iter1_1       EQU  $15E8
iter1_2       EQU $15EA
iter2_1       EQU  $15EC                                        
iter2_2       EQU $15EE
lastAdd     EQU  $15D0                                           ;
carry       EQU  $15D8
carryLeast  EQU  $15D9                                        ; carry nin 8bitse least significantý
operation        EQU  $15E0                                   ; yapilacak islemi tutacak

; variable/data section

            ORG  plus
 FCC        "+-"
            ORG  myStr 
 FCC        "639.25 - 458.36 ="
            ORG  myStr
            
            
; code section
            ORG   ROMStart



Entry:
_Startup:
            LDS   #RAMEnd+1       ; initialize the stack pointer

            CLI                     ; enable interrupts
                                                                                   ; count ý sýfýrla
            LDX   #myStr
            STX   iter                                                                                ; iter e adres ver
            
            LDAA  #$00                          
            STAA  count   
            JSR   copyNum1_1 
                   
            LDAA  #$00                          
            STAA  count                                                                          ; count ý sýfýrla
            JSR   copyNum2_1
            
            LDAA  #$00                          
            STAA  count                                                                          ; count ý sýfýrla
            JSR   copyNum1_2
            
            
            LDAA  #$00                          
            STAA  count                                                                          ; count ý sýfýrla
            JSR   copyNum2_2
            
            ;;;;;;;;;;;;;;;;;;;;;;;hepsinden 30 cikartacagim;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            
            LDAA #$06
            STAA tempo
            
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;item1_1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            LDX  #item1_1
            LDAB #$30
            
     for1:  LDAA 0,X
            SBA
            STAA 0,X
            INX
            LDAA tempo
            DECA
            STAA tempo   
            BNE  for1
            
            ;;;;;;;;;;;;;;;;;;;;;;;;item2_1;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            LDAA #$06
            STAA tempo
            
            LDX  #item2_1
            LDAB #$30
            
     for2:  LDAA 0,X
            SBA
            STAA 0,X
            INX
            LDAA tempo
            DECA
            STAA tempo   
            BNE  for2
            
            LDX   temp                                                                            ; ikinci sayinin baslangic adresi var
            DEX                                                                                        ; iki azaltýp operation + mý - mi diye bakicaz
            DEX 
            
            LDAA  plus
            LDAB  0,X     
            STAB  operation
            SBA                                                                                            ; A = A - B
            BEQ   goPlus                                                                            ; if plus op jmp plus
            
            LDAA  minus
            LDAB  0,X     
            SBA             
            BEQ   goMinus                                                                      ; else if op minus sa jmp minus
            BRA   cont
            
goPlus:      jsr   OpPlus

goMinus:    
            jsr   OpMinus 
            
cont:       
            LDAA  #$06                                                                            ; 6 digit var 6kere donecek loop
            STAA  tempo
            LDX   #$15FD
            STX   lastAdd 
            LDAA  #$00                                                                             ; carry en basta 00'dir
            STAA  carryLeast
            
            LDAA  operation
            LDAB  minus
            SBA   
            BEQ   carryMinus
            
carryCheck:    
            LDY   lastAdd
            LDAB  0,Y
            
            
            LDAA  carryLeast                                                                   ; CARRY ile topla
            ABA
            STAA  0,Y
            LDAA  #$00
            LDAB  0,Y
            LDX   #$0A 
            
            IDIV
            LDAA  #$30
            ABA
            STAA  0,Y
            STX   carry
            
            DEY
            STY   lastAdd
            LDAA  tempo
            DECA
            STAA  tempo
            BNE   carryCheck 
            BRA   last
 
carryMinus:
            LDY   lastAdd
            LDAB  0,Y
            LDAA  carryLeast                                                              ; CARRY ile topla
            ABA
            STAA  0,Y
            LDAA  #$00
            STAA  carryLeast
            LDAA  0,Y
            BMI   revert                                                                         ; 0'dan kucukse 10 ekleyecek
            LDAB  #$30                                                                       ; $30 EKLEYECEK STRNG ICIN  (karakter olarak yazilabilmesiicin)
            ABA
            STAA  0,Y
enLast:     
            DEY
            STY   lastAdd
            LDAA  tempo
            DECA
            STAA  tempo
            BNE   carryMinus
            BRA   last            

revert:     
            LDAA  0,Y
            LDAB  #$0A     
            ABA   
            LDAB  #$30                                                                                              ; $30 EKLEYECEK STRNG ICIN
            ABA
            STAA  0,Y
            LDAA  #$FF
            STAA  carryLeast
            BRA   enLast            
            

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;SONUC YAZ $1600 E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;     

;;;;;;;;;;;;;;;;;;;;;;;,sonucun tam kismi;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,       
last:      
            LDAA  #$06                                                                                             ; 6 digit var 6kere donecek loop
            STAA  tempo 
            
            LDX   #tempRes
            LDY   #result
writeRes:   
            LDAB  0,X
            SUBB  #$30                                                                                          ; 30 DEGILSE YAZCAK
            BNE   store
            INX
            LDAA  tempo
            DECA
            STAA  tempo
            BRA   writeRes
            
store:      
            LDAA  0,X
            STAA  0,Y
            INY 
            INX
            LDAA  tempo
            DECA
            STAA  tempo
            BNE   store
            BRA   Continue
            
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;sonucun double kismi;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;,                      
                     
Continue:     
           JSR   EXIT
            

OpPlus:       
            LDAA  #$06
            STAA  tempCount
            LDX   #tempRes
            STX   tempTRES
            
            LDX   #item1_1
            LDY   #item2_1
            
            STX   iter1_1
            STY   iter2_1
            
    loopPlus1_1: 
            LDX   iter1_1
            LDY   iter2_1 
                               
            LDAA  0,X                                                                                                            ; item1_1 in digitleri
            LDAB  0,Y                                                                                                            ; item2_1 nin digitleri   
            INX
            INY   
            STX   iter1_1
            STY   iter2_1
            
            ABA                                                                                                                     ; A = A + B
            
            LDX   tempTRES
            STAA  0,X                                                                                                          ; sonucu kaybetmemek icin sakliyoruz
            INX
            STX   tempTRES
            LDAA  tempCount 
            DECA  
            STAA  tempCount
            BNE   loopPlus1_1
            
            
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ondalik kismin islemi
            LDAA #$06
             STAA  tempCount
            LDX   #tempRes
            STX   tempTRES
            
            LDX   #item1_2
            LDY   #item2_2
            
            STX   iter1_2
            STY   iter2_2
            
    loopPlus_2: 
            LDX   iter1_2
            LDY   iter2_2 
                               
            LDAA  0,X                                                                                                            ; item1_2 in digitleri
            LDAB  0,Y                                                                                                            ; item2_2 nin digitleri   
            INX
            INY   
            STX   iter1_2
            STY   iter2_2
            
            ABA                                                                                                                     ; A = A + B
            
            LDX   tempTRES
            STAA  0,X                                                                                                          ; sonucu kaybetmemek icin sakliyoruz
            INX
            STX   tempTRES
            LDAA  tempCount 
            DECA  
            STAA  tempCount
            BNE   loopPlus_2
            
            JSR   cont
             
OpMinus:      

            LDAA  #$06
            STAA  tempCount
            LDX   #tempRes
            STX   tempTRES
            
            LDX   #item1_1
            LDY   #item2_1
            
            STX   iter1_1
            STY   iter2_1
            
    loopMinus: 
            LDX   iter1_1
            LDY   iter2_1 
                               
            LDAA  0,X                                                                                                               ; item1_1 in digitleri
            LDAB  0,Y                                                                                                               ; item2_1 nin digitleri   
            INX
            INY   
            STX   iter1_1
            STY   iter2_1
            SBA                                                                                                                        ; A = A - B
            
            LDX   tempTRES
            STAA  0,X                                                                                                               ;sonucu sakla
            INX
            STX   tempTRES
            LDAA  tempCount 
            DECA  
            STAA  tempCount
            BNE   loopMinus   
             
          
           LDAA  #$06
           STAA  tempCount
           LDX   #tempRes
           STX   tempTRES
           
           LDX   #item1_1
           LDY   #item2_1
            
           STX   iter1_1
           STY   iter2_1
            
    loopMinus_2: 
            LDX   iter1_2
            LDY   iter2_2 
                               
            LDAA  0,X                                                                                                               ; item1_2 in digitleri
            LDAB  0,Y                                                                                                               ; item2_2 nin digitleri   
            INX
            INY   
            STX   iter1_2
            STY   iter2_2
            SBA                                                                                                                        ; A = A - B
            
            LDX   tempTRES
            STAA  0,X                                                                                                               ;sonucu sakla
            INX
            STX   tempTRES
            LDAA  tempCount 
            DECA  
            STAA  tempCount
            BNE   loopMinus_2  
           
            JSR   cont 
                    
          
copyNum1_1:

Loop1_1:       
            LDX   iter         
            LDAA  0,X                                                                                                            ; arrayin[i] elemanýný al
            
            LDX   iter
            INX
            STX   iter                                                                                                              ; iter u 1 arttýr
            
            LDAB   count
            INCB
            STAB   count                                                                                                      ; count ý 1 arttýr            
            
            LDAB  #dot
            SBA   
            BNE   Loop1_1                                                                                                        ; " " karakteri deglse 
                    
          
            ;;;;;;;;;;;;;;;;;;;;;;;count 1 fazla cikiyor 1 azalt;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            LDAB   count
            DECB                                                                                                                  ; count ý 1 azaltýr
            
            LDAA   #$06                      
            SBA        
            STAA   count                                                                                                     ; basina kac 0 koycagmizi anlamk icn
            
            ;;;;;;;;;;;;;;;;;;;;;;;count kadar donecek loop;;;;;;;;;;;;;;;;;;;
            LDAB  count
            LDX   #item1_1
            LDAA  #$30
            
     LoopX1_1:   
            STAA  0,X                                                                                                         ; 6digit varmis gibi baslarina 0 koycak
            INX
            
            DECB
            BNE   LoopX1_1
            
            LDAB   count
            LDAA   #$06                      
            SBA        
            STAA   count 
            
            LDAA  count
            LDY   #myStr 
            
     LoopY1_1:
            ;X'DE digit i kopyalicagmiz adres var
            ;Y'ye de array[i] adresimizi almamýz lazm
                        
            MOVB  0,Y, 0,X 
            INY 
            INX
            DECA
            BNE   LoopY1_1       ;        
            
                   
            ;Y'ye 1 eklersek  noktayi atlamis olcak
            INY
            ;INY
            ;INY
            STY  iter                                                                                                                 ; yukarýdaki islemleri tekrarlaycaz
            
            RTS


copyNum1_2:  
            LDX   iter
            STX   temp  
Loop1_2:       
            LDX   iter         
            LDAA  0,X                                                                                                            ; arrayin[i] elemanýný al
            
            LDX   iter
            INX
            STX   iter                                                                                                              ; iter u 1 arttýr
            
            LDAB   count
            INCB
            STAB   count                                                                                                      ; count ý 1 arttýr            
            
            LDAB  #space
            SBA   
            BNE   Loop1_2                                                                                                        ; " " karakteri deglse 
                    
          
            ;;;;;;;;;;;;;;;;;;;;;;;count 1 fazla cikiyor 1 azalt;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            LDAB   count
            DECB                                                                                                                  ; count ý 1 azaltýr
            
            LDAA   #$06                      
            SBA        
            STAA   count                                                                                                     ; basina kac 0 koycagmizi anlamk icn
            
            ;;;;;;;;;;;;;;;;;;;;;;;count kadar donecek loop;;;;;;;;;;;;;;;;;;;
            LDAB  count
            LDX   #item1_2
            LDAA  #$30
            
     LoopX1_2:   
            STAA  0,X                                                                                                         ; 6digit varmis gibi baslarina 0 koycak
            INX
            
            DECB
            BNE   LoopX1_2
            
            LDAB   count
            LDAA   #$06                      
            SBA        
            STAA   count 
            
            LDAA  count
            LDY   #temp
            
     LoopY1_2:
            ;X'DE digit i kopyalicagmiz adres var
            ;Y'ye de array[i] adresimizi almamýz lazm
                        
            MOVB  0,Y, 0,X 
            INY 
            INX
            DECA
            BNE   LoopY1_2       ;        
            
                   
            ;Y'ye 3 eklersek  islemi atlamis olcak
            INY
            INY
            INY
            STY  iter                                                                                                                 ; yukarýdaki islemleri tekrarlaycaz
            
            RTS
            


copyNum2_1:
            LDX   iter
            STX   temp   
Loop2_1:       
            LDX   iter     
            LDAA  0,X                                                                                                            ; arrayin[i] elemanýný al
           
            LDX   iter
            INX
            STX   iter                                                                                                             ; iter u 1 arttýr
            
            LDAB   count
            INCB
            STAB   count                                                                                                      ; count ý 1 arttýr 
            
            LDAB  #dot
            SBA   
            BNE   Loop2_1                                                                                                    ; " " karakteri degilse 
          
            ;;;;;;count 1 fazla cikiyor 1 azalt
            LDAB   count
            DECB                                                                                                              ; count ý 1 azaltýr
            
            LDAA   #$06                      
            SBA        
            STAA   count                                                                                                ; basina kac 0 koycagmizi anlamk icn
            
            LDAB  count
            LDX   #item2_1
            LDAA  #$30
            
     LoopX2_1:  
            STAA  0,X                                                                                                    ; 6digit varmis gibi baslarina 0 koycak
            INX
            
            DECB
            BNE   LoopX2_1
            
            LDAB   count
            LDAA   #$06                      
            SBA        
            STAA   count  
            
            LDAA  count
            LDY   temp 
            
            
     LoopY2_1:
            ;X'DE digit i kopyalicagmiz adres var
            ;Y'ye de array[i] adresimizi almamýz lazm
                        
            MOVB  0,Y, 0,X 
            INY 
            INX
            DECA
            BNE   LoopY2_1       ;        
            
                   
            ;Y'ye 1 eklersek  ' . ' yi atlamis olcak
            INY
            ;INY
            ;INY
            STY  iter                                                                                                                           ; yukarýdaki islemleri tekrarlaycaz
            
            RTS

    
copyNum2_2:
            LDX   iter
            STX   temp  
Loop2_2:       
            LDX   iter         
            LDAA  0,X                                                                                                            ; arrayin[i] elemanýný al
            
            LDX   iter
            INX
            STX   iter                                                                                                              ; iter u 1 arttýr
            
            LDAB   count
            INCB
            STAB   count                                                                                                      ; count ý 1 arttýr            
            
            LDAB  #space
            SBA   
            BNE   Loop2_2                                                                                                        ; " " karakteri deglse 
                    
          
            ;;;;;;;;;;;;;;;;;;;;;;;count 1 fazla cikiyor 1 azalt;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            LDAB   count
            DECB                                                                                                                  ; count ý 1 azaltýr
            
            LDAA   #$06                      
            SBA        
            STAA   count                                                                                                     ; basina kac 0 koycagmizi anlamk icn
            
            ;;;;;;;;;;;;;;;;;;;;;;;count kadar donecek loop;;;;;;;;;;;;;;;;;;;
            LDAB  count
            LDX   #item2_2
            LDAA  #$30
            
     LoopX2_2:   
            STAA  0,X                                                                                                         ; 6digit varmis gibi baslarina 0 koycak
            INX
            
            DECB
            BNE   LoopX2_2
            
            LDAB   count
            LDAA   #$06                      
            SBA        
            STAA   count 
            
            LDAA  count
            LDY   #temp
            
     LoopY2_2:
            ;X'DE digit i kopyalicagmiz adres var
            ;Y'ye de array[i] adresimizi almamýz lazm
                        
            MOVB  0,Y, 0,X 
            INY 
            INX
            DECA
            BNE   LoopY2_2       ;        
            
                   
            ;Y'ye 2 eklersek  ' = ' isaretine gelmis olacak
            INY
            INY
           ; INY
            STY  iter   
            
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; sonda = var mi kontrolu
            
            LDAA 0,Y
            CMPA #equal
            BNE NOEQ
            
            RTS

;;;;;;;;;;, ifadenin sonunda = yoksa PORTB yi yakar($FF verir ve butun bitleri yakar)
NOEQ:
        LDAA #$FF
        STAA DDRB
        STAA PORTB
        JMP EXIT


            
 EXIT:     
            END
;**************************************************************
;*                 Interrupt Vectors                          *
;**************************************************************
            ORG   $FFFE
            DC.W  Entry           ; Reset Vector
