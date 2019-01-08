
sbi DDRB, 5 //led output
cbi DDRC, 0 //LDR input
sbi PORTC, 0 //pull up resistor 
 
//---- Conversion starts here ----//

LDI R16 , 0x87
STS ADCSRA, R16
LDI R16 , 0x40
STS ADMUX, R16
//configurations done
 
READ_ADC:
//CBI PORTB,5
LDS R18, ADCSRA
SBR R18,0b01000000
STS ADCSRA,R18
 
KEEP_POLING :
LDS R19, ADCSRA
SBRS R19, 4
//
RJMP KEEP_POLING // loop bc conversion not complegted ADIGF =0+
 
 
LDS R16, ADCSRA
SBR R16,0b00010000
STS ADCSRA,R16
 
// above is setting bit 4 to 1 indicating that conversion over
 
//below is reading the high and low byte of the ADC
LDS R16,ADCL //8 bits
LDS R17,ADCH // read 2 bits
 
 
LDI R20, 0Xf4
CP R16,R20 //IF R16>=R20
BRGE greateq // The low bits are greater than 244 so if ADCH has a value of one which is 2^8=256+244=500
CP R20,R16 //IF R20> R16 (It's dim)
BRGE check
 
greateq:
LDI R21,0X01 //Here we are checking if it is greater than or equal to one (2^8 on or more)
CP R17,R21 //R17>=R21
brge light
CP R21, R17
brge dim
 
check: // The ADCL has a decimal value lower than 244 so we need either 2^9 or both 2^8 and 2^9 but ( 2^8 alone is not enough )
LDI R23,0x02 // Greater than or equal to 2 aka either (2^9 is on) or (2^8 and 2^9 together are on)
CP R17,R23
brge light
CP R23, R17
brge dim
 
light:
CBI PORTB, 5 // Turns OFF the LED
NOP
NOP
NOP
NOp
RJMP READ_ADC
 
dim:
SBI PORTB, 5 // Turns ON the LED*
NOP
NOP
NOP
NOP
 
RJMP READ_ADC
 
 
//ZERO SO WE SELECTED RIGHT SO MOST SIGN 6 0s
 
//RJMP READ_ADC
 