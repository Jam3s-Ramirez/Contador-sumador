//*****************************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programación de microcontroladores
// Autor: James Ramírez
// Proyecto: Prelab1.asm
// Descripción: Código de ejemplo Hola Mundo
// Hardware: ATMega328p
// Creado: 24/01/2024
//*****************************************************************************

// Encabezado
.include "M328PDEF.inc"

.cseg
.org 0x00

//*****************************************************************************
// Configuración de la Pila
//*****************************************************************************
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17

//*****************************************************************************
// Configuración MCU
//*****************************************************************************
	.equ DELAY_COUNT = 255  ; Ajusta este valor según sea necesario para tu aplicación

DELAY:
	LDI R21, DELAY_COUNT
DELAY_LOOP:
	DEC R21
	BRNE DELAY_LOOP
	RET

SETUPC1:
   // Configuración de pines
   LDI R16, 0b11111100  ; Configura los pines PB0-PB3 como entrada y PB4-PB7 como salida
   OUT DDRC, R16

   // Habilita las resistencias de pull-up en los pines de entrada
   LDI R16, (1 << PC0) | (1 << PC1)  // Se añade el pulsador para la suma en PC2
   OUT PORTC, R16

   // Inicializa el contador en 0
   LDI R18, 0

SETUPC2:
   // Configuración de pines
   LDI R20, 0b11110000  ; Configura los pines PB0-PB3 como entrada y PB4-PB7 como salida
   OUT DDRD, R20

   // Habilita las resistencias de pull-up en los pines de entrada
   LDI R20, (1 << PD0) | (1 << PD1) | (1 << PD2)
   OUT PORTD, R20

   // Inicializa el contador en 0
   LDI R22, 0

SETUPB:
   // Configura el puerto B como salida
   LDI R24, 0b11011111
   OUT DDRB, R24

MAIN_LOOP:

SBIC PINC, PC0         ; Comprueba el estado del pulsador de incremento.
   RJMP CHECK_DEBOUNCE_C1

   SBIC PINC, PC1         ; Comprueba el estado del pulsador de decremento.
   RJMP CHECK_DEBOUNCE_C1

   SBIC PINC, PC2         ; Comprueba el estado del pulsador de suma.
   RJMP CHECK_DEBOUNCE_C1

   SBIC PIND, PD0         ; Comprueba el estado del pulsador de incremento.
   RJMP CHECK_DEBOUNCE_C2

   SBIC PIND, PD1         ; Comprueba el estado del pulsador de decremento.
   RJMP CHECK_DEBOUNCE_C2

   RJMP MAIN_LOOP        ; Si detecta que ninguno de los pulsadores está activo, reinicia el proceso hasta detectar un cambio.

CHECK_DEBOUNCE_C1:
   CALL DELAY             ; Espera un tiempo para el antirrebote
   SBIC PINC, PC0         ; Comprueba nuevamente el estado del pulsador de incremento.
   RJMP INC_COUNTERC1

   SBIC PINC, PC1         ; Comprueba nuevamente el estado del pulsador de decremento.
   RJMP DEC_COUNTERC1

   SBIC PINC, PD2         ; Comprueba nuevamente el estado del pulsador de suma.
   RJMP ADD_COUNTERS

   RJMP MAIN_LOOP        ; Si el botón sigue siendo presionado, vuelve al MAIN_LOOP.

CHECK_DEBOUNCE_C2:
   CALL DELAY             ; Espera un tiempo para el antirrebote
   SBIC PIND, PD0         ; Comprueba nuevamente el estado del pulsador de incremento.
   RJMP INC_COUNTERC2

   SBIC PIND, PD1         ; Comprueba nuevamente el estado del pulsador de decremento.
   RJMP DEC_COUNTERC2

   RJMP MAIN_LOOP        ; Si el botón sigue siendo presionado, vuelve al MAIN_LOOP.

INC_COUNTERC1:

   INC R18               // Incrementa en 1 el valor del contador.
   OUT PORTC, R18        // Muestra el valor de R18 en los bits más significativos de PORTC
   RJMP MAIN_LOOP        // Realiza un salto al MAIN_LOOP

DEC_COUNTERC1:

   CPI R18, 0            // Compara el valor de R18 para determinar si puede seguir decrementando o no.
   BREQ MAIN_LOOP        // Regresa al módulo MAIN_LOOP
   DEC R18               // Decrementa el contador y verifica que no sea negativo.
   OUT PORTC, R18        // Muestra el valor de R18 en los bits más significativos de PORTC
   RJMP MAIN_LOOP        // Realiza un salto al MAIN_LOOP.

RESET_COUNTERC1:

   LDI R18, 0            // Reinicia el contador a 0.
   OUT PORTC, R18        // Muestra el valor de R18 en los bits más significativos de PORTC
   RJMP MAIN_LOOP        // Salta al MAIN_LOOP.

INC_COUNTERC2:

   INC R22               // Incrementa en 1 el valor del contador.
   OUT PORTD, R22        // Muestra el valor de R22 en los bits más significativos de PORTD
   RJMP MAIN_LOOP        // Realiza un salto al MAIN_LOOP

DEC_COUNTERC2:

   CPI R22, 0            // Compara el valor de R22 para determinar si puede seguir decrementando o no.
   BREQ MAIN_LOOP        // Regresa al módulo MAIN_LOOP
   DEC R22               // Decrementa el contador y verifica que no sea negativo.
   OUT PORTD, R22        // Muestra el valor de R22 en los bits más significativos de PORTD
   RJMP MAIN_LOOP        // Realiza un salto al MAIN_LOOP.

RESET_COUNTERC2:

   LDI R22, 0            // Reinicia el contador a 0.
   OUT PORTD, R22        // Muestra el valor de R22 en los bits más significativos de PORTD
   RJMP MAIN_LOOP        // Salta al MAIN_LOOP.

ADD_COUNTERS:
   ADD R24, R18          // Suma el valor de R18 al registro R24 (puerto B)
   ADC R25, R22          // Suma el valor de R22 al registro R25, teniendo en cuenta el acarreo
   OUT PORTB, R24        // Muestra el resultado de la suma en el puerto B
   OUT PORTB, R25        // Si hay un acarreo, el bit 7 de PORTB se encenderá
   RJMP MAIN_LOOP        // Salta al MAIN_LOOP.
