; Proyecto Unidad 3 - Lenguajes de Interfaz
; Docente: Dr. Jose Luis Medina Jimenez
; Tienda de Electronica: inventario y ventas 
; Integrantes: Jose Angel Grande Espinoza, Jesus Ivan Martinez Reyes, Angel Ernesto Santos Plazola

; Regla de negocio: alerta de existencia minima
; Si un producto queda con 5 piezas o menos se avisa que hay que resurtir

; Cambios de la Unidad 3: procedimientos nuevos, macros y USES

INCLUDE Irvine32.inc

; ---- MostrarMensaje ----
; Muestra un texto y salta de linea
; Cambia: EDX
MostrarMensaje MACRO texto
    mov  edx, OFFSET texto
    call WriteString
    call Crlf
ENDM

; ---- MostrarTexto ----
; Muestra un texto sin saltar de linea
; Cambia: EDX
MostrarTexto MACRO texto
    mov  edx, OFFSET texto
    call WriteString
ENDM

; ---- MostrarDato ----
; Muestra un texto, despues un numero y salta de linea.
; Cambia: EAX, EDX
MostrarDato MACRO texto, valor
    mov  edx, OFFSET texto
    call WriteString
    mov  eax, valor
    call MostrarNumero
    call Crlf
ENDM
; ---- MostrarDinero ----
; Igual que MostrarDato pero el valor son centavos
; Cambia: EAX, EDX
MostrarDinero MACRO texto, valor
    mov  edx, OFFSET texto
    call WriteString
    mov  eax, valor
    call MostrarImporte
    call Crlf
ENDM

; ---- MostrarFicha ----
; Cambia: EDX
MostrarFicha MACRO
    mov  edx, OFFSET txtCodigo
    call WriteString
    call MostrarProducto
ENDM
; ---- LeerTexto ----
; Lee lo que escribe el usuario con ReadString
; Deja EAX = cuantos caracteres se escribieron
; Cambia: EAX, ECX, EDX
LeerTexto MACRO buffer, maximo
    mov  edx, OFFSET buffer
    mov  ecx, maximo
    call ReadString
ENDM
; ---- RechazarVacio ----
; Se usa justo despues de LeerTexto. Si no se escribio nada (EAX = 0)
; muestra el aviso y regresa a la etiqueta donde se vuelve a pedir
; Cambia: EDX
RechazarVacio MACRO etiquetaPedir
    LOCAL hayTexto
    cmp  eax, 0
    jne  hayTexto
    MostrarMensaje msgVacio
    jmp  etiquetaPedir
hayTexto:
ENDM
; ---- ValidarTexto ----
; Llama a un procedimiento que revisa o convierte un texto,
; pasandole ESI = buffer y ECX = largo (el EAX que dejo LeerTexto)
; Cambia: ESI, ECX y lo que regrese el procedimiento
ValidarTexto MACRO procedimiento, buffer
    mov  esi, OFFSET buffer
    mov  ecx, eax
    call procedimiento
ENDM

; ---- ValidarCampo ----
; Igual que ValidarTexto pero con el campo leido del archivo (bufCampo)
; Guarda ESI porque ahi va la posicion dentro del archivo
; Cambia: ECX y lo que regrese el procedimiento
ValidarCampo MACRO procedimiento
    push esi
    ValidarTexto procedimiento, bufCampo
    pop  esi
ENDM

; ---- SaltarSiFuera ----
; Si valor < minimo o valor > maximo, salta a la etiqueta de error.
; Comparacion sin signo (JB / JA).
SaltarSiFuera MACRO valor, minimo, maximo, etiquetaError
    cmp  valor, minimo
    jb   etiquetaError
    cmp  valor, maximo
    ja   etiquetaError
ENDM

; ---- SaltarSiSuficiente ----
; Regla de negocio: existencia minima de 5 piezas.
; Si la existencia es MAYOR que 5 salta (no hay alerta).
; El 5 solo esta escrito aqui, asi si cambia la regla se cambia en un lugar.
SaltarSiSuficiente MACRO existencia, etiqueta
    cmp  existencia, 5
    ja   etiqueta
ENDM
; ---- CalcularImporte ----
; EAX = precio * cantidad. Si el resultado no cabe en 32 bits
; (EDX distinto de 0) salta a la etiqueta de desbordamiento.
; Cambia: EAX, EDX
CalcularImporte MACRO precio, cantidad, etiquetaDesborde
    mov  eax, precio
    mov  edx, cantidad
    mul  edx                        ; EDX:EAX = precio * cantidad
    cmp  edx, 0
    jne  etiquetaDesborde
ENDM

; ---- SiguienteCampo ----
; Lee un campo del archivo y revisa que despues venga el '|'.
; Deja EAX = largo del campo y ESI despues del '|'.
; Cambia: EAX, EBX, ESI
SiguienteCampo MACRO etiquetaError
    call LeerCampo
    mov  bl, [esi]
    cmp  bl, '|'
    jne  etiquetaError
    inc  esi
ENDM
; ---- ErrorArchivo ----
; Guarda el motivo del error del archivo y salta a paError
ErrorArchivo MACRO mensaje
    mov  msgErrArch, OFFSET mensaje
    jmp  paError
ENDM

.data
; ---- catalogo ----
catalogo     BYTE 440 DUP(0)
numProd      DWORD 0
catTemp      BYTE 440 DUP(0)
numTemp      DWORD 0
; ---- datos de la sesion ----
ingresos     DWORD 0
ventasHechas DWORD 0
hayCambios   DWORD 0
; ---- buffers ----
bufEntrada   BYTE 81 DUP(0)
bufCodigo    BYTE 8 DUP(0)
bufNombre    BYTE 26 DUP(0)
bufNum       BYTE 11 DUP(0)
bufCampo     BYTE 41 DUP(0)
; ---- validacion ----
limiteMin    DWORD ?
limiteMax    DWORD ?
msgPedir     DWORD ?
precioPesos  DWORD ?
precioCent   DWORD ?
diez         DWORD 10
cien         DWORD 100
nuevoPrecio  DWORD ?
nuevaExis    DWORD ?
cantidad     DWORD ?
importe      DWORD ?
nuevosIngresos DWORD ?
centavosTmp  DWORD ?
cuantosBajos DWORD ?
; ---- archivo ----
archDefault  BYTE "inventario.txt",0
nombreArch   BYTE 61 DUP(0)
handleArch   DWORD ?
bufArchivo   BYTE 1001 DUP(0)
bytesPedidos DWORD ?
bytesLeidos  DWORD ?
lineaArch    DWORD ?
msgErrArch   DWORD ?
txtSep       BYTE "|",0
txtFinLinea  BYTE 0Dh,0Ah,0

; ---- mensajes ----
msgTitulo   BYTE "=====================================================",0Dh,0Ah
            BYTE "     TIENDA DE ELECTRONICA  -  Inventario y Ventas",0Dh,0Ah
            BYTE "=====================================================",0
msgMenu     BYTE " 1. Registrar producto",0Dh,0Ah
            BYTE " 2. Mostrar inventario",0Dh,0Ah
            BYTE " 3. Buscar producto por codigo",0Dh,0Ah
            BYTE " 4. Recibir mercancia",0Dh,0Ah
            BYTE " 5. Vender",0Dh,0Ah
            BYTE " 6. Resumen",0Dh,0Ah
            BYTE " 7. Guardar catalogo",0Dh,0Ah
            BYTE " 8. Cargar catalogo",0Dh,0Ah
            BYTE " 0. Salir",0Dh,0Ah
            BYTE "Opcion: ",0
msgOpcionMal BYTE "  Opcion no valida, escribe un numero del 0 al 8",0

msgPideCodigo  BYTE "Codigo (formato ABC-123):",0
msgPideNombre  BYTE "Nombre (1 a 25 caracteres): ",0
msgPidePrecio  BYTE "Precio en MXN (ejempl: 185.50): ",0
msgPideExis    BYTE "Existencia inicial (0 a 100): ",0
msgPideCantE   BYTE "Unidades recibidas: ",0
msgPideCantV   BYTE "Unidades a vender: ",0

msgVacio       BYTE "  No se permiten datos vacios",0
msgCodMal      BYTE "  Codigo incorrecto. Deben ser 3 letras MAYUSCULAS, guion y 3 digitos",0
msgNomMal      BYTE "  Nombre invalido (1 a 25 caracteres, sin '|' y sin iniciar con espacio)",0
msgPrecioMal   BYTE "  Precio con formato incorrecto. Usa solo digitos y un punto con 1 o 2 decimales",0
msgPrecioRango BYTE "  Precio fuera de rango ($0.01 a $9999.99 MXN)",0
msgNumMal      BYTE "  Solo se permiten digitos (sin signos, espacios ni punto)",0
msgRango1      BYTE "  Valor fuera de rango. Debe estar entre ",0
msgRango2      BYTE " y ",0

msgLleno       BYTE "  Catalogo lleno: ya hay 10 productos registrados",0
msgDuplicado   BYTE "  Ese codigo ya existe. No se registro el producto",0
msgRegistrado  BYTE "  Producto registrado",0
msgNoExiste    BYTE "  No existe un producto con ese codigo",0
msgEncontrado  BYTE "  Producto encontrado:",0
msgSinProd     BYTE "  (No hay productos registrados)",0
msgInvTitulo   BYTE "---------------- INVENTARIO ----------------",0

msgExcede1     BYTE "  Rechazado: se excederian las 100 unidades. Solo caben ",0
msgExcede2     BYTE " unidades mas.",0
msgRecibido    BYTE "  Mercancia recibida. Nueva existencia: ",0

msgSinExis     BYTE "  Venta rechazada: el producto no tiene existencias",0
msgInsuf1      BYTE "  Venta rechazada: existencias insuficientes (hay ",0
msgInsuf2      BYTE ").",0
msgDesborde    BYTE "  Operacion rechazada: desbordamiento en el calculo.",0
msgTicket      BYTE "---------------- TICKET DE VENTA ----------------",0
msgTkPrecio    BYTE "  Precio unitario : ",0
msgTkCant      BYTE "  Cantidad        : ",0
msgTkTotal     BYTE "  TOTAL A PAGAR   : ",0
msgVendido     BYTE "  Venta registrada. Existencia restante: ",0
msgAlerta      BYTE "  ALERTA: quedan 5 piezas o menos, hay que resurtir este producto.",0
msgSinAlerta   BYTE "  Existencia suficiente (mas de 5 piezas), no hay alerta.",0

msgResTitulo   BYTE "------------------- RESUMEN -------------------",0
msgResProd     BYTE "  Productos registrados   : ",0
msgResUnid     BYTE "  Unidades disponibles    : ",0
msgResValor    BYTE "  Valor del inventario    : ",0
msgResIngr     BYTE "  Ingresos de la sesion   : ",0
msgResVentas   BYTE "  Ventas realizadas       : ",0
msgResBajos    BYTE "  Productos por resurtir  : ",0

msgPideArch    BYTE "Nombre del archivo (Enter = inventario.txt): ",0
msgNadaGuardar BYTE "  No hay productos para guardar.",0
msgErrCrear    BYTE "  No se pudo crear el archivo.",0
msgErrEscribir BYTE "  Error al escribir: no se escribieron todos los bytes.",0
msgGuardado1   BYTE "  Catalogo guardado. Bytes escritos: ",0
msgErrAbrir    BYTE "  El archivo no existe o no se pudo abrir. Se conserva el catalogo actual.",0
msgErrLeer     BYTE "  Error al leer el archivo. Se conserva el catalogo actual.",0
msgArchVacio   BYTE "  El archivo esta vacio. Se conserva el catalogo actual.",0
msgArchGrande  BYTE "  El archivo es demasiado grande. Se conserva el catalogo actual.",0
msgArchMal1    BYTE "  Archivo invalido, linea ",0
msgArchMal2    BYTE ": ",0
msgArchMal3    BYTE "      No se cargo nada, se conserva el catalogo actual.",0
msgCargado1    BYTE "  Catalogo cargado. Productos: ",0
msgBytesLei    BYTE "  Bytes leidos del archivo: ",0

errFormato     BYTE "formato de linea incorrecto",0
errCodigo      BYTE "codigo invalido",0
errDupl        BYTE "codigo duplicado",0
errNombre      BYTE "nombre invalido",0
errPrecio      BYTE "precio invalido o fuera de rango",0
errExis        BYTE "existencia invalida o fuera de rango",0
errMuchos      BYTE "hay mas de 10 productos",0
errNinguno     BYTE "no contiene productos",0

msgSalirAviso  BYTE "Hay cambios sin guardar. Guardar antes de salir? (S/N): ",0

txtCodigo      BYTE "  ",0
txtBarra       BYTE " | ",0
txtExis        BYTE " | Exist: ",0
txtBaja        BYTE "  EXISTENCIA BAJA",0
txtParen       BYTE ") ",0
txtPesos       BYTE "$",0
txtPunto       BYTE ".",0
txtCero        BYTE "0",0
txtMXN         BYTE " MXN",0

.code
; ---- main ----
; Muestra el menu, lee la opcion y llama al procedimiento que toca.
; Se repite hasta que el usuario escribe 0.
main PROC
menuPrincipal:
    call Crlf
    MostrarMensaje msgTitulo        
    MostrarTexto msgMenu            
    call LeerOpcion                 ; EAX = opcion elegida (o -1 si no sirve)
    call Crlf

    cmp  eax, 1                     ; comparamos la opcion con cada numero
    je   opRegistrar
    cmp  eax, 2
    je   opInventario
    cmp  eax, 3
    je   opBuscar
    cmp  eax, 4
    je   opRecibir
    cmp  eax, 5
    je   opVender
    cmp  eax, 6
    je   opResumen
    cmp  eax, 7
    je   opGuardar
    cmp  eax, 8
    je   opCargar
    cmp  eax, 0
    je   opSalir

    MostrarMensaje msgOpcionMal     ; si no fue ninguna, opcion invalida
    jmp  menuPrincipal

opRegistrar:
    call RegistrarProducto
    jmp  menuPrincipal
opInventario:
    call MostrarInventario
    jmp  menuPrincipal
opBuscar:
    call BuscarProducto
    jmp  menuPrincipal
opRecibir:
    call RecibirMercancia
    jmp  menuPrincipal
opVender:
    call VenderProducto
    jmp  menuPrincipal
opResumen:
    call MostrarResumen
    jmp  menuPrincipal
opGuardar:
    call GuardarCatalogo
    jmp  menuPrincipal
opCargar:
    call CargarCatalogo
    jmp  menuPrincipal

opSalir:
    call ConfirmarSalida            ; pregunta si hay cambios sin guardar
    exit
main ENDP
; ---- LeerOpcion ----
; Recibe: nada
; Regresa: EAX = opcion de 0 a 8, o -1 si no es valida
; Cambia: EAX
; Conserva (USES): EBX, ECX, EDX, ESI
LeerOpcion PROC USES ebx ecx edx esi
    LeerTexto bufEntrada, 80        ; EAX = cuantos caracteres se escribieron
    cmp  eax, 1                     ; la opcion debe ser de 1 caracter
    jne  loInvalida

    ValidarTexto ConvertirEntero, bufEntrada   ; EAX = numero, EBX = 1 si era valido
    cmp  ebx, 1
    jne  loInvalida                 ; no era un digito
    cmp  eax, 8
    ja   loInvalida          ; mayor a 8 no existe en el menu
    jmp  loFin

loInvalida:
    mov  eax, -1                    ; -1 = opcion no valida
loFin:
    ret                             ; USES saca los registros antes de regresar
LeerOpcion ENDP

; ---- ValidarCodigo ----
; Revisa el formato ABC-123
; Recibe: ESI = direccion del texto, ECX = largo
; Regresa: EAX = 1 si es valido, 0 si no
; Cambia: EAX
; Conserva (USES): EBX, ECX, ESI
ValidarCodigo PROC USES ebx ecx esi
    cmp  ecx, 7              ; el codigo mide exactamente 7
    jne  vcMal

    mov  ebx, 0             ; EBX = posicion (0, 1, 2)
vcLetras:
    mov  al, [esi] ; AL = caracter actual
    cmp  al, 'A'            ; menor que 'A' no es mayuscula
    jb   vcMal
    cmp  al, 'Z'          ; mayor que 'Z' no es mayuscula
    ja   vcMal
    inc  esi                        
    inc  ebx                        
    cmp  ebx, 3       ; repetimos mientras sea menor a 3
    jb   vcLetras

    mov  al, [esi]        ; posicion 3: debe ser el guion
    cmp  al, '-'
    jne  vcMal
    inc  esi

    mov  ecx, 3               ; faltan 3 digitos, LOOP usa ECX
vcDigitos:
    mov  al, [esi]
    cmp  al, '0'              ; menor que '0' no es digito
    jb   vcMal
    cmp  al, '9'             ; mayor que '9' no es digito
    ja   vcMal
    inc  esi
    loop vcDigitos                  ; ECX - 1, repite si no es 0

    mov  eax, 1                     ; paso todo, es valido
    jmp  vcFin
vcMal:
    mov  eax, 0                     ;  fallo brotheeeer
vcFin:
    ret
ValidarCodigo ENDP

; ---- ValidarNombre ----
; Recibe: ESI = direccion del texto, ECX = largo
; Regresa: EAX = 1 si es valido, 0 si no
; Cambia: EAX
; Conserva (USES): ECX, ESI
ValidarNombre PROC USES ecx esi
    SaltarSiFuera ecx, 1, 25, vnMal ; de 1 a 25 caracteres

    mov  al, [esi]                  ; revisamos la primera letra
    cmp  al, ' '                    ; no puede empezar con espacio
    je   vnMal

vnCiclo:
    mov  al, [esi]       ; AL = caracter actual
    cmp  al, ' '        ; menor a espacio = caracter de control
    jb   vnMal
    cmp  al, '|'      ; el '|' separa los campos en el archivo
    je   vnMal
    inc  esi               
    loop vnCiclo                    ; se repite una vez por cada caracter

    mov  eax, 1                     ; nombre valido
    jmp  vnFin
vnMal:
    mov  eax, 0                     ; nombre invalido
vnFin:
    ret
ValidarNombre ENDP

; ---- ConvertirEntero ----
; Convierte un texto de digitos a numero: acumulado = acumulado * 10 + digito
; Recibe: ESI = direccion del texto, ECX = largo
; Regresa: EAX = numero, EBX = 1 si es valido, 0 si no
; Cambia: EAX, EBX
; Conserva (USES): ECX, EDX, ESI, EDI
ConvertirEntero PROC USES ecx edx esi edi
    mov  eax, 0                     ; acumulado empieza en 0
    cmp  ecx, 0                     ; texto vacio
    je   ceMal
    mov  edi, 10                    ; EDI = 10 para multiplicar

ceCiclo:
    mov  ebx, 0                     ; limpiamos EBX
    mov  bl, [esi]                  ; BL = caracter actual
    cmp  bl, '0'                    ; si no esta entre '0' y '9' no es digito
    jb   ceMal
    cmp  bl, '9'
    ja   ceMal
    sub  bl, '0'                    ; '7' - '0' = 7 (de caracter a numero)

    mul  edi                        ; EDX:EAX = acumulado * 10
    cmp  edx, 0                     ; si EDX no es 0 ya no cabe en 32 bits
    jne  ceMal
    add  eax, ebx                   ; le sumamos el digito
    jb   ceMal                      ; CF = 1 (acarreo): se desbordo

    inc  esi                        ; siguiente caracter
    loop ceCiclo

    mov  ebx, 1                     ; todo bien
    jmp  ceFin
ceMal:
    mov  eax, 0
    mov  ebx, 0                     ; no es valido
ceFin:
    ret
ConvertirEntero ENDP

; ---- ConvertirPrecio ----
; Convierte un precio en pesos a centavos: "185.50" -> 18550
; Ahora busca el punto y usa ConvertirEntero para los pesos y para
; los centavos, en lugar de repetir la conversion digito por digito
;Recibe: ESI = direccion del texto, ECX = largo
; Regresa: EAX = centavos, EBX = 1 valido, 0 formato malo, 2 fuera de rango
; Cambia: EAX, EBX
; Conserva (USES): ECX, EDX, ESI, EDI
ConvertirPrecio PROC USES ecx edx esi edi
    mov  precioCent, 0              ; si no hay punto, no hay centavos

    mov  edx, 0                     ; EDX = posicion del punto
cpBuscar:
    cmp  edx, ecx                   
    jae  cpSinPunto
    mov  al, [esi + edx]
    cmp  al, '.'
    je   cpConPunto
    inc  edx
    jmp  cpBuscar

cpSinPunto:                         ; "185": todo son pesos
    call ConvertirEntero            ; ESI y ECX ya traen el texto
    cmp  ebx, 1
    jne  cpFormato
    mov  precioPesos, eax
    jmp  cpArmar

cpConPunto:
    cmp  edx, 0                     ; ".50": no hay pesos antes del punto
    je   cpFormato
    mov  edi, ecx                   ; EDI = digitos despues del punto
    sub  edi, edx                   ;       (largo - posicion - 1)
    dec  edi
    SaltarSiFuera edi, 1, 2, cpFormato  ; "185." o "185.505" no se aceptan

    mov  ecx, edx                   ; pesos = los caracteres antes del punto
    call ConvertirEntero
    cmp  ebx, 1
    jne  cpFormato
    mov  precioPesos, eax

    add  esi, edx                   ; ESI = primer decimal (despues del punto)
    inc  esi
    mov  ecx, edi
    call ConvertirEntero            ; "18.5.0": "5.0" trae otro punto y se rechaza
    cmp  ebx, 1
    jne  cpFormato
    cmp  edi, 2                     ; con 2 decimales ya son centavos
    je   cpGuardarCent
    mul  diez                       ; con 1 decimal: 185.5 son 50 centavos
cpGuardarCent:
    mov  precioCent, eax

cpArmar:
    cmp  precioPesos, 9999          ; mas de 9999 pesos no se acepta
    ja   cpRango
    mov  eax, precioPesos
    mul  cien                       ; pesos * 100
    add  eax, precioCent            ; + centavos
    SaltarSiFuera eax, 1, 999999, cpRango   ; de $0.01 a $9999.99
    mov  ebx, 1                     ; precio valido
    jmp  cpFin

cpFormato:
    mov  eax, 0
    mov  ebx, 0      ; formato incorrecto
    jmp  cpFin
cpRango:
    mov  eax, 0
    mov  ebx, 2   ; fuera de rango
cpFin:
    ret
ConvertirPrecio ENDP

; ---- CapturarCodigo ----
; Pide el codigo hasta que sea valido y lo copia a bufCodigo
; Recibe: nada
; Regresa: bufCodigo con el codigo
; Cambia: nada
; Conserva (USES): EAX, ECX, EDX, ESI, EDI
CapturarCodigo PROC USES eax ecx edx esi edi
ccPedir:
    MostrarTexto msgPideCodigo
    LeerTexto bufEntrada, 80        ; EAX = caracteres leidos
    RechazarVacio ccPedir           ; si dio solo Enter, se pide otra vez
    ValidarTexto ValidarCodigo, bufEntrada  ; EAX = 1 si el formato es correcto
    test eax, eax
    jz   ccMal

    mov  esi, OFFSET bufEntrada     ; copiamos los 7 caracteres + 00h
    mov  edi, OFFSET bufCodigo
    mov  ecx, 8
    call CopiarBytes
    jmp  ccFin

ccMal:
    MostrarMensaje msgCodMal
    jmp  ccPedir
ccFin:
    ret
CapturarCodigo ENDP

; ---- CapturarNombre ----
; Pide el nombre hasta que sea valido y lo copia a bufNombre
; Recibe: nada
; Regresa: bufNombre con el nombre
; Cambia: nada
; Conserva (USES): EAX, ECX, EDX, ESI, EDI
CapturarNombre PROC USES eax ecx edx esi edi
cnPedir:
    MostrarTexto msgPideNombre
    LeerTexto bufEntrada, 80        ; dejamos escribir de mas para saber si pasa de 25
    RechazarVacio cnPedir
    ValidarTexto ValidarNombre, bufEntrada  ; EAX = 1 si es valido
    test eax, eax
    jz   cnMal

    inc  ecx                        ; largo + 1 para copiar tambien el 00h
    mov  esi, OFFSET bufEntrada     ; (ValidarNombre conserva ECX)
    mov  edi, OFFSET bufNombre
    call CopiarBytes
    jmp  cnFin

cnMal:
    MostrarMensaje msgNomMal
    jmp  cnPedir
cnFin:
    ret
CapturarNombre ENDP

; ---- CapturarPrecio ----
; Pide el precio hasta que sea valido
; Recibe: nada
; Regresa: EAX = precio en centavos
; Cambia: EAX
; Conserva (USES): EBX, ECX, EDX, ESI
CapturarPrecio PROC USES ebx ecx edx esi
cprPedir:
    MostrarTexto msgPidePrecio
    LeerTexto bufEntrada, 80
    RechazarVacio cprPedir
    ValidarTexto ConvertirPrecio, bufEntrada  ; EAX = centavos, EBX = resultado
    cmp  ebx, 1      ; 1 = valido
    je   cprListo
    cmp  ebx, 2     ; 2 = fuera de rango
    je   cprRango

    MostrarMensaje msgPrecioMal   ; 0 = formato incorrecto
    jmp  cprPedir
cprRango:
    MostrarMensaje msgPrecioRango
    jmp  cprPedir
cprListo:
    ret
CapturarPrecio ENDP

; ---- CapturarNumero ----
; Pide un numero entero hasta que este dentro del rango
; Recibe: EDX = mensaje, EBX = minimo, ECX = maximo
; Regresa: EAX = numero
; Cambia: EAX
; Conserva (USES): EBX, ECX, EDX, ESI
CapturarNumero PROC USES ebx ecx edx esi
    mov  msgPedir, edx      ; guardamos los datos porque LeerTexto
    mov  limiteMin, ebx       ; usa EDX y ECX
    mov  limiteMax, ecx

cnuPedir:
    mov  edx, msgPedir  ; mostramos el mensaje que nos pasaron
    call WriteString
    LeerTexto bufEntrada, 80
    RechazarVacio cnuPedir
    ValidarTexto ConvertirEntero, bufEntrada ; EAX = numero, EBX = 1 si es valido
    cmp  ebx, 1
    jne  cnuNoNumero
    SaltarSiFuera eax, limiteMin, limiteMax, cnuRango
    jmp  cnuFin ; numero correcto

cnuNoNumero:
    MostrarMensaje msgNumMal
    jmp  cnuPedir
cnuRango:
    MostrarTexto msgRango1  ; "Debe estar entre X y Y"
    mov  eax, limiteMin
    call MostrarNumero
    MostrarDato msgRango2, limiteMax
    jmp  cnuPedir
cnuFin:
    ret
CapturarNumero ENDP
; ---- convertirDecimal ----
; Convierte un numero a texto dividiendo entre 10
; Recibe: EAX = numero, ESI = direccion del buffer (11 bytes)
; Regresa: el texto en el buffer, EAX = cuantos digitos tiene
; Cambia: EAX
; Conserva (USES): EBX, ECX, EDX, ESI
convertirDecimal PROC USES ebx ecx edx esi
    mov  ebx, 10     ; dividimos entre 10
    mov  ecx, 0    ; ECX cuenta los digitos
cdDividir:
    mov  edx, 0   ; EDX en 0 porque DIV usa EDX:EAX
    div  ebx      ; EAX = cociente, EDX = residuo (el digito)
    push edx     ; guardamos el digito en la pila
    inc  ecx    
    cmp  eax, 0 ; si el cociente no es 0, seguimos
    jne  cdDividir

    mov  ebx, ecx         ; guardamos cuantos digitos son
cdArmar:
    pop  edx                 ; sale primero el ultimo que entro
    add  dl, '0'      ; numero a caracter ASCII
    mov  [esi], dl      ; lo ponemos en el buffer
    inc  esi                    ; siguiente posicion
    loop cdArmar               ; tantos POP como PUSH: la pila queda igual

    mov  dl, 0
    mov  [esi], dl                  ; 00h al final de la cadena
    mov  eax, ebx                   ; EAX = cuantos digitos
    ret
convertirDecimal ENDP

; ---- MostrarNumero ----
; Recibe: EAX = numero a mostrar
; Regresa: nada
; Cambia: nada
; Conserva (USES): EAX, EDX, ESI
MostrarNumero PROC USES eax edx esi
    mov  esi, OFFSET bufNum         ; ESI = buffer donde queda el texto
    call convertirDecimal           ; numero = texto
    mov  edx, OFFSET bufNum
    call WriteString                ; mostramos el texto
    ret
MostrarNumero ENDP

; ---- MostrarImporte ----
; Muestra centavos como $pesos.centavos MXN (18550 = $185.50 MXN)
; Recibe: EAX = importe en centavos
; Regresa: nada
; Cambia: nada
; Conserva (USES): EAX, EBX, EDX
MostrarImporte PROC USES eax ebx edx
    mov  edx, 0                     ; EDX en 0 para dividir EDX:EAX
    mov  ebx, 100
    div  ebx                        ; EAX = pesos, EDX = centavos
    mov  centavosTmp, edx           ; guardamos los centavos

    MostrarTexto txtPesos           ; "$"
    call MostrarNumero              ; pesos
    MostrarTexto txtPunto           ; "."

    mov  eax, centavosTmp
    cmp  eax, 10                    ; si son 10 o mas ya tienen 2 digitos
    jae  miCentavos
    MostrarTexto txtCero            ; si no, ponemos un 0 antes (5 = 05)
miCentavos:
    call MostrarNumero              ; centavos
    MostrarTexto txtMXN             ; " MXN"
    ret
MostrarImporte ENDP

; ---- MostrarProducto ----
; Muestra un producto en un renglon. Si tiene 5 o menos piezas
; agrega la marca de existencia baja.
; Recibe: ESI = direccion del producto
; Regresa: nada
; Cambia: nada
; Conserva (USES): EAX, EDX
MostrarProducto PROC USES eax edx
    mov  edx, esi                   ; codigo (byte 0 del producto)
    call WriteString
    MostrarTexto txtBarra
    mov  edx, esi
    add  edx, 8                     ; nombre (byte 8 del producto)
    call WriteString
    MostrarTexto txtBarra
    mov  eax, [esi + 36]            ; precio (byte 36)
    call MostrarImporte
    MostrarTexto txtExis
    mov  eax, [esi + 40]            ; existencia (byte 40)
    call MostrarNumero

    SaltarSiSuficiente eax, mpFin   ; regla: mas de 5 piezas, no se marca
    MostrarTexto txtBaja            ; 5 o menos: existencia baja
mpFin:
    call Crlf
    ret
MostrarProducto ENDP
; ---- CopiarBytes ----
; Copia bytes de un lugar a otro, uno por uno
; Recibe: ESI = origen, EDI = destino, ECX = cuantos bytes
; Regresa: los bytes copiados en el destino
; Cambia: nada
; Conserva (USES): EAX, ECX, ESI, EDI
CopiarBytes PROC USES eax ecx esi edi
    cmp  ecx, 0                     ; si son 0 bytes no hay nada que copiar
    je   cbFin
cbCiclo:
    mov  al, [esi]                  ; leemos un byte del origen
    mov  [edi], al                  ; lo escribimos en el destino
    inc  esi
    inc  edi
    loop cbCiclo
cbFin:
    ret
CopiarBytes ENDP

; ---- AgregarTexto ----
; Copia un texto (sin su 00h) al final de lo que se esta armando
; Recibe: EDX = texto, EDI = donde se va a copiar
; Regresa: EDI = posicion siguiente al ultimo caracter copiado
; Cambia: EDI
; Conserva (USES): EAX, EDX
AgregarTexto PROC USES eax edx
atCiclo:
    mov  al, [edx]                  ; caracter del texto
    cmp  al, 0                      ; si es 00h ya terminamos
    je   atFin
    mov  [edi], al                  ; lo copiamos
    inc  edx
    inc  edi
    jmp  atCiclo
atFin:
    ret
AgregarTexto ENDP

; ---- AgregarNumero ----  (nuevo)
; Convierte un numero a texto y lo copia al final de lo que se esta
; armando. Antes esto se repetia para el precio y la existencia.
; Recibe: EAX = numero, EDI = donde se va a copiar
; Regresa: EDI = posicion siguiente al ultimo digito copiado
; Cambia: EDI
; Conserva (USES): EAX, EDX, ESI
AgregarNumero PROC USES eax edx esi
    mov  esi, OFFSET bufNum
    call convertirDecimal           ; numero = texto en bufNum
    mov  edx, OFFSET bufNum
    call AgregarTexto               ; lo copiamos donde apunta EDI
    ret
AgregarNumero ENDP

;  BuscarCodigo 
; Recorre un catalogo con ESI comparando el codigo de cada producto
; Recibe: EDX = codigo buscado, ESI = direccion del catalogo, ECX = cuantos productos
; Regresa: EAX = numero de producto (0 a 9) o -1, ESI = direccion del producto
; Cambia: EAX, ESI
; Conserva (USES): EBX, ECX, EDI
BuscarCodigo PROC USES ebx ecx edi
    mov  edi, ecx                 ; guardamos el total para sacar el numero
    cmp  ecx, 0            ; catalogo vacio
    je   bcNoEsta

bcProducto:
    mov  ebx, 0                   ; EBX = posicion dentro del codigo
bcComparar:
    mov  al, [esi + ebx]     ; caracter del producto
    cmp  al, [edx + ebx]    ; contra el caracter buscado
    jne  bcSiguiente            ; si es diferente, no es este
    inc  ebx
    cmp  ebx, 7         ; revisamos los 7 caracteres
    jb   bcComparar

    mov  eax, edi       ; lo encontramos
    sub  eax, ecx       ; numero = total - los que faltaban
    jmp  bcFin

bcSiguiente:
    add  esi, 44        ; ESI pasa al siguiente producto
    loop bcProducto

bcNoEsta:
    mov  eax, -1   ; no se encontro
bcFin:
    ret
BuscarCodigo ENDP
;  PedirProductoExistente 
; Pide un codigo y lo busca en el catalogo
; Regresa: EAX = numero de producto o -1, ESI = direccion del producto
; Cambia: EAX, ESI
; Conserva (USES): ECX, EDX
PedirProductoExistente PROC USES ecx edx
    call CapturarCodigo       ; deja el codigo en bufCodigo
    mov  edx, OFFSET bufCodigo
    mov  esi, OFFSET catalogo
    mov  ecx, numProd
    call BuscarCodigo
    cmp  eax, -1
    jne  ppFin
    MostrarMensaje msgNoExiste  ; no esta registrado
ppFin:
    ret
PedirProductoExistente ENDP
; RegistrarProducto (opcion 1) 

; Conserva (USES): EAX, EBX, ECX, EDX, ESI, EDI
RegistrarProducto PROC USES eax ebx ecx edx esi edi
    cmp  numProd, 10     ; si ya hay 10 no cabe otro
    jae  rpLleno

    call CapturarCodigo          ; codigo con formato correcto
    mov  edx, OFFSET bufCodigo
    mov  esi, OFFSET catalogo
    mov  ecx, numProd
    call BuscarCodigo        ; revisamos que no exista
    cmp  eax, -1
    jne  rpDuplicado        ; si se encontro, esta duplicado

    call CapturarNombre       ; nombre en bufNombre
    call CapturarPrecio      ; precio en EAX
    mov  nuevoPrecio, eax
    mov  edx, OFFSET msgPideExis
    mov  ebx, 0        ; existencia minima 0
    mov  ecx, 100      ; existencia maxima 100
    call CapturarNumero
    mov  nuevaExis, eax

    mov  eax, numProd    ; direccion = catalogo + numProd * 44
    mov  ebx, 44
    mul  ebx
    mov  edi, OFFSET catalogo
    add  edi, eax      ; EDI = donde va el nuevo producto

    mov  esi, OFFSET bufCodigo  ; copiamos el codigo (byte 0)
    mov  ecx, 8
    call CopiarBytes
    add  edi, 8      ; copiamos el nombre (byte 8)
    mov  esi, OFFSET bufNombre
    mov  ecx, 26
    call CopiarBytes
    sub  edi, 8         ; regresamos al inicio del producto
    mov  eax, nuevoPrecio
    mov  [edi + 36], eax   ; precio (byte 36)
    mov  eax, nuevaExis
    mov  [edi + 40], eax    ; existencia (byte 40)

    inc  numProd       ; un producto mas
    mov  hayCambios, 1              ; hay cambios sin guardar
    MostrarMensaje msgRegistrado
    mov  esi, edi                   ; mostramos el producto registrado
    MostrarFicha
    jmp  rpFin

rpLleno:
    MostrarMensaje msgLleno
    jmp  rpFin
rpDuplicado:
    MostrarMensaje msgDuplicado
rpFin:
    ret
RegistrarProducto ENDP

; ---- MostrarInventario (opcion 2) ----
; Recibe: nada
; Regresa: nada
; Cambia: nada
; Conserva (USES): EAX, EBX, ECX, EDX, ESI
MostrarInventario PROC USES eax ebx ecx edx esi
    MostrarMensaje msgInvTitulo
    cmp  numProd, 0                 ; no hay productos
    je   miVacio

    mov  esi, OFFSET catalogo       ; ESI = primer producto
    mov  ecx, numProd               ; ECX = cuantos hay (para LOOP)
    mov  ebx, 1                     ; numero de renglon
miCiclo:
    mov  eax, ebx
    call MostrarNumero              ; "1"
    MostrarTexto txtParen           ; ") "
    call MostrarProducto            ; datos del producto
    add  esi, 44                    ; siguiente producto
    inc  ebx
    loop miCiclo
    jmp  miFin

miVacio:
    MostrarMensaje msgSinProd
miFin:
    ret
MostrarInventario ENDP

; ---- BuscarProducto (opcion 3) ----
; Recibe: nada
; Regresa: nada
; Cambia: nada
; Conserva (USES): EAX, EDX, ESI
BuscarProducto PROC USES eax edx esi
    call PedirProductoExistente     ; EAX = numero, ESI = producto
    cmp  eax, -1                    ; no se encontro
    je   bpFin
    MostrarMensaje msgEncontrado
    MostrarFicha
bpFin:
    ret
BuscarProducto ENDP

; ---- RecibirMercancia (opcion 4) ----
; Suma unidades a un producto sin pasar de 100
; Recibe: nada
; Regresa: nada
; Cambia: nada
; Conserva (USES): EAX, EBX, ECX, EDX, ESI
RecibirMercancia PROC USES eax ebx ecx edx esi
    call PedirProductoExistente
    cmp  eax, -1
    je   rmFin
    MostrarFicha

    mov  edx, OFFSET msgPideCantE
    mov  ebx, 1                     ; minimo 1 (mayor que cero)
    mov  ecx, 100                   ; maximo 100
    call CapturarNumero             ; EAX = unidades recibidas

    mov  ebx, [esi + 40]            ; EBX = existencia actual
    add  ebx, eax                   ; + lo que llego
    cmp  ebx, 100                   ; no puede pasar de 100
    ja   rmExcede

    mov  [esi + 40], ebx            ; ahora si guardamos la nueva existencia
    mov  hayCambios, 1
    MostrarDato msgRecibido, ebx
    jmp  rmFin

rmExcede:
    MostrarTexto msgExcede1
    mov  eax, 100
    sub  eax, [esi + 40]      ; cuantas caben todavia
    call MostrarNumero
    MostrarMensaje msgExcede2
rmFin:
    ret
RecibirMercancia ENDP

; ---- VenderProducto (opcion 5) ----
; Revisa existencias, calcula el importe y descuenta las unidades
; Al final aplica la regla: si quedan 5 piezas o menos muestra la alerta
; Conserva (USES): EAX, EBX, ECX, EDX, ESI
VenderProducto PROC USES eax ebx ecx edx esi
    call PedirProductoExistente     ; ESI = producto
    cmp  eax, -1
    je   vpFin
    MostrarFicha

    mov  eax, [esi + 40]         ; existencia
    cmp  eax, 0              ; si no hay nada, no se puede vender
    je   vpSinExis

    mov  edx, OFFSET msgPideCantV
    mov  ebx, 1         
    mov  ecx, 100    
    call CapturarNumero
    mov  cantidad, eax

    cmp  eax, [esi + 40]       
    ja   vpInsuficiente

    CalcularImporte [esi+36], cantidad, vpDesborde  ; EAX = precio * cantidad
    mov  importe, eax

    mov  eax, ingresos
    add  eax, importe
    jb   vpDesborde           ; CF = 1 (acarreo): no cabe
    mov  nuevosIngresos, eax

    ; hasta aqui no se ha cambiado nada, ahora si se actualiza
    mov  eax, cantidad
    sub  [esi + 40], eax            ; existencia - cantidad
    mov  eax, nuevosIngresos
    mov  ingresos, eax              ; ingresos + importe
    inc  ventasHechas
    mov  hayCambios, 1

    call Crlf
    MostrarMensaje msgTicket
    MostrarDinero msgTkPrecio, [esi+36]
    MostrarDato msgTkCant, cantidad
    MostrarDinero msgTkTotal, importe
    MostrarDato msgVendido, [esi+40]

    ; regla de negocio: alerta de existencia minima
    mov  eax, [esi + 40]
    SaltarSiSuficiente eax, vpSinAlerta
    MostrarMensaje msgAlerta      ; 5 o menos, hay que resurtir
    jmp  vpFin
vpSinAlerta:
    MostrarMensaje msgSinAlerta
    jmp  vpFin

vpSinExis:
    MostrarMensaje msgSinExis
    jmp  vpFin
vpInsuficiente:
    MostrarTexto msgInsuf1
    mov  eax, [esi + 40]
    call MostrarNumero
    MostrarMensaje msgInsuf2
    jmp  vpFin
vpDesborde:
    MostrarMensaje msgDesborde
vpFin:
    ret
VenderProducto ENDP

; ---- MostrarResumen (opcion 6) ----
; Suma unidades, valor del inventario y cuenta los productos por resurtir
; Conserva (USES): EAX, EBX, ECX, EDX, ESI, EDI
MostrarResumen PROC USES eax ebx ecx edx esi edi
    mov  ebx, 0            ; EBX = total de unidades
    mov  edi, 0               ; EDI = valor del inventario
    mov  cuantosBajos, 0     ; productos con 5 o menos
    mov  ecx, numProd
    cmp  ecx, 0
    je   mrMostrar

    mov  esi, OFFSET catalogo   ; ESI = primer producto
mrCiclo:
    mov  eax, [esi + 40]           ; existencia
    add  ebx, eax                  ; sumamos unidades
    SaltarSiSuficiente eax, mrValor ; regla: 5 o menos se cuenta
    inc  cuantosBajos
mrValor:
    CalcularImporte [esi+40], [esi+36], mrDesborde  ; existencia * precio
    add  edi, eax       ; sumamos al valor
    jb   mrDesborde     ; CF = 1 (acarreo): no cabe
    add  esi, 44        ; siguiente producto
    loop mrCiclo

mrMostrar:
    MostrarMensaje msgResTitulo
    MostrarDato msgResProd, numProd
    MostrarDato msgResUnid, ebx
    MostrarDinero msgResValor, edi
    MostrarDinero msgResIngr, ingresos
    MostrarDato msgResVentas, ventasHechas
    MostrarDato msgResBajos, cuantosBajos
    jmp  mrFin

mrDesborde:
    MostrarMensaje msgDesborde
mrFin:
    ret
MostrarResumen ENDP

; ---- PedirNombreArchivo ----
; Pide el nombre del archivo; si solo dan Enter se usa inventario.txt
; Regresa: nombreArch con el nombre
; Conserva (USES): EAX, ECX, EDX, ESI, EDI
PedirNombreArchivo PROC USES eax ecx edx esi edi
    MostrarTexto msgPideArch
    LeerTexto nombreArch, 60   ; nombreArch mide 61 (60 + 00h)
    cmp  eax, 0               ; si escribio algo, se usa eso
    jne  pnFin
    mov  esi, OFFSET archDefault ; si no, copiamos "inventario.txt"
    mov  edi, OFFSET nombreArch
    mov  ecx, 15            ; 14 letras + 00h
    call CopiarBytes
pnFin:
    ret
PedirNombreArchivo ENDP

; ---- ArmarTextoArchivo ----
; Escribe en bufArchivo una linea por producto: CODIGO|NOMBRE|PRECIO|EXISTENCIA
; Regresa: EAX = cuantos bytes se armaron
; Conserva (USES): ECX, EDX, ESI, EDI
ArmarTextoArchivo PROC USES ecx edx esi edi
    mov  edi, OFFSET bufArchivo   ; EDI = donde vamos escribiendo
    mov  esi, OFFSET catalogo   ; ESI = producto actual
    mov  ecx, numProd
atCicloProd:
    mov  edx, esi         ; codigo
    call AgregarTexto
    mov  edx, OFFSET txtSep  ; "|"
    call AgregarTexto
    mov  edx, esi
    add  edx, 8            ; nombre
    call AgregarTexto
    mov  edx, OFFSET txtSep
    call AgregarTexto
    mov  eax, [esi + 36]      ; precio en centavos
    call AgregarNumero
    mov  edx, OFFSET txtSep
    call AgregarTexto
    mov  eax, [esi + 40]    ; existencia
    call AgregarNumero
    mov  edx, OFFSET txtFinLinea ; salto de linea
    call AgregarTexto

    add  esi, 44      ; siguiente producto
    loop atCicloProd

    mov  eax, edi     ; bytes = donde terminamos - donde empezamos
    sub  eax, OFFSET bufArchivo
    ret
ArmarTextoArchivo ENDP

; ---- GuardarCatalogo (opcion 7) ----
; Regresa: hayCambios = 0 si se guardo bien
; Conserva (USES): EAX, ECX, EDX
GuardarCatalogo PROC USES eax ecx edx
    cmp  numProd, 0       ; no hay nada que guardar
    je   gcNada

    call PedirNombreArchivo
    call ArmarTextoArchivo      ; EAX = bytes a escribir
    mov  bytesPedidos, eax         ; lo guardamos para comparar despues

    mov  edx, OFFSET nombreArch ; EDX = nombre del archivo
    call CreateOutputFile         ; EAX = handle
    cmp  eax, INVALID_HANDLE_VALUE  ; no se pudo crear
    je   gcErrCrear
    mov  handleArch, eax

    mov  eax, handleArch   ; EAX = handle
    mov  edx, OFFSET bufArchivo   ; EDX = que vamos a escribir
    mov  ecx, bytesPedidos         ; ECX = cuantos bytes
    call WriteToFile                ; EAX = bytes que si se escribieron
    push eax                       ; lo guardamos mientras cerramos
    mov  eax, handleArch
    call CloseFile  ; cerramos el archivo
    pop  eax
    cmp  eax, bytesPedidos   ; se escribio todo?
    jne  gcErrEscribir

    mov  hayCambios, 0              ; ya no hay cambios pendientes
    MostrarDato msgGuardado1, eax   ; bytes escritos
    jmp  gcFin

gcNada:
    MostrarMensaje msgNadaGuardar
    jmp  gcFin
gcErrCrear:
    MostrarMensaje msgErrCrear
    jmp  gcFin
gcErrEscribir:
    MostrarMensaje msgErrEscribir
gcFin:
    ret
GuardarCatalogo ENDP
; ---- LeerCampo ----
; Copia a bufCampo un campo del archivo, hasta '|', CR, LF o 00h
; Recibe: ESI = posicion en bufArchivo
; Regresa: EAX = largo del campo (0 si pasa de 40), ESI = en el separador
; Cambia: EAX, ESI
; Conserva (USES): EBX
LeerCampo PROC USES ebx
    mov  ebx, 0                     ; EBX = caracteres del campo
lcCiclo:
    mov  al, [esi]                  ; caracter actual
    cmp  al, '|'                    ; separador
    je   lcFin
    cmp  al, 0Dh                    ; CR
    je   lcFin
    cmp  al, 0Ah                    ; LF
    je   lcFin
    cmp  al, 0                      ; fin del texto
    je   lcFin
    cmp  ebx, 40                    ; campo demasiado largo
    jae  lcLargo
    mov  bufCampo[ebx], al          ; copiamos el caracter
    inc  ebx
    inc  esi
    jmp  lcCiclo

lcLargo:
    mov  ebx, 0                     ; lo marcamos vacio para que se rechace
lcFin:
    mov  bufCampo[ebx], 0           ; 00h al final del campo
    mov  eax, ebx                   ; EAX = largo
    ret
LeerCampo ENDP
; ---- ProcesarArchivo ----
; Arma el catalogo en catTemp a partir del texto leido, revisando cada campo
; Recibe: bufArchivo con el texto y 00h al final
; Regresa: EAX = 1 si todo esta bien, 0 si no (motivo en msgErrArch)
; Cambia: EAX
; Conserva (USES): EBX, ECX, EDX, ESI, EDI
ProcesarArchivo PROC USES ebx ecx edx esi edi
    mov  numTemp, 0
    mov  lineaArch, 0
    mov  esi, OFFSET bufArchivo     ; ESI recorre el texto del archivo
    mov  edi, OFFSET catTemp        ; EDI = producto que se esta llenando

paLinea:
    mov  al, [esi]  ; saltamos CR y LF sobrantes
    cmp  al, 0Dh
    je   paSaltar
    cmp  al, 0Ah
    je   paSaltar
    cmp  al, 0       ; fin del texto
    je   paFinTexto
    jmp  paNueva
paSaltar:
    inc  esi
    jmp  paLinea

paNueva:
    inc  lineaArch     ; una linea mas
    cmp  numTemp, 10   ; ya hay 10, no cabe otra
    jae  paMuchos

    ; campo 1: codigo
    SiguienteCampo paFormato  ; EAX = largo, ESI despues del '|'
    ValidarCampo ValidarCodigo      ; mismo procedimiento que en el teclado
    test eax, eax
    jz   paCodigo
    push esi
    mov  edx, OFFSET bufCampo  ; que no se repita en el archivo
    mov  esi, OFFSET catTemp
    mov  ecx, numTemp
    call BuscarCodigo
    pop  esi
    cmp  eax, -1
    jne  paDuplicado
    push esi
    mov  esi, OFFSET bufCampo ; copiamos el codigo (byte 0)
    mov  ecx, 8
    call CopiarBytes
    pop  esi

    ; campo 2: nombre
    SiguienteCampo paFormato
    ValidarCampo ValidarNombre
    test eax, eax
    jz   paNombre
    push esi
    push edi
    mov  esi, OFFSET bufCampo
    add  edi, 8     ; nombre (byte 8)
    inc  ecx        ; largo + 00h
    call CopiarBytes
    pop  edi
    pop  esi

    ; campo 3: precio en centavos
    SiguienteCampo paFormato
    ValidarCampo ConvertirEntero  ; EAX = numero, EBX = valido
    cmp  ebx, 1
    jne  paPrecio
    SaltarSiFuera eax, 1, 999999, paPrecio  ; $0.01 a $9999.99
    mov  [edi + 36], eax            ; precio (byte 36)

    ; campo 4: existencia (despues viene fin de linea)
    call LeerCampo
    mov  bl, [esi]
    cmp  bl, '|'           ; no debe haber un quinto campo
    je   paFormato
    ValidarCampo ConvertirEntero
    cmp  ebx, 1
    jne  paExis
    cmp  eax, 100         ; maximo 100
    ja   paExis
    mov  [edi + 40], eax     ; existencia (byte 40)

    inc  numTemp      ; producto completo
    add  edi, 44    ; siguiente producto en catTemp
    jmp  paLinea

paFinTexto:
    cmp  numTemp, 0   ; el archivo no traia productos
    je   paNinguno
    mov  eax, 1       ; todo bien
    jmp  paFin

paFormato:
    ErrorArchivo errFormato
paCodigo:
    ErrorArchivo errCodigo
paDuplicado:
    ErrorArchivo errDupl
paNombre:
    ErrorArchivo errNombre
paPrecio:
    ErrorArchivo errPrecio
paExis:
    ErrorArchivo errExis
paMuchos:
    ErrorArchivo errMuchos
paNinguno:
    ErrorArchivo errNinguno
paError:
    mov  eax, 0   ; archivo invalido
paFin:
    ret
ProcesarArchivo ENDP

; ---- CargarCatalogo (opcion 8) ----
; Lee el archivo, lo revisa y solo si esta bien reemplaza el catalogo
; Regresa: catalogo y numProd nuevos si el archivo es valido
; Conserva (USES): EAX, ECX, EDX, ESI, EDI
CargarCatalogo PROC USES eax ecx edx esi edi
    call PedirNombreArchivo

    mov  edx, OFFSET nombreArch     ; EDX = nombre del archivo
    call OpenInputFile              ; EAX = handle
    cmp  eax, INVALID_HANDLE_VALUE  ; no existe o no se pudo abrir
    je   ccaNoAbre
    mov  handleArch, eax

    mov  edx, OFFSET bufArchivo   ; EDX = donde se guarda lo leido
    mov  ecx, 1000          ; ECX = maximo 1000 bytes (dejamos 1 para el 00h)
    call ReadFromFile           ; EAX = bytes leidos, CF = 1 si hubo error
    jb   ccaErrLeer                 ; CF = 1: error al leer
    mov  bytesLeidos, eax
    mov  eax, handleArch
    call CloseFile                 

    MostrarDato msgBytesLei, bytesLeidos
    cmp  bytesLeidos, 0             ; archivo vacio
    je   ccaVacio
    cmp  bytesLeidos, 1000          ; lleno el buffer, puede que falte texto
    jae  ccaGrande

    mov  esi, bytesLeidos           ; ESI = posicion despues del ultimo byte
    mov  bufArchivo[esi], 0         ; ahi ponemos el 00h

    call ProcesarArchivo            ; revisamos todo el archivo
    test eax, eax
    jz   ccaInvalido

    mov  eax, numTemp       ; bytes a copiar = numTemp * 44
    mov  ecx, 44
    mul  ecx
    mov  ecx, eax
    mov  esi, OFFSET catTemp   ; copiamos catTemp al catalogo
    mov  edi, OFFSET catalogo
    call CopiarBytes
    mov  eax, numTemp
    mov  numProd, eax
    mov  hayCambios, 0        ; recien cargado, no hay cambios

    MostrarDato msgCargado1, numProd
    call MostrarInventario
    jmp  ccaFin

ccaNoAbre:
    MostrarMensaje msgErrAbrir
    jmp  ccaFin
ccaErrLeer:
    mov  eax, handleArch      ; aunque fallo, cerramos el archivo
    call CloseFile
    MostrarMensaje msgErrLeer
    jmp  ccaFin
ccaVacio:
    MostrarMensaje msgArchVacio
    jmp  ccaFin
ccaGrande:
    MostrarMensaje msgArchGrande
    jmp  ccaFin
ccaInvalido:
    MostrarTexto msgArchMal1        ; "Archivo invalido, linea X: motivo"
    mov  eax, lineaArch
    call MostrarNumero
    MostrarTexto msgArchMal2
    mov  edx, msgErrArch            ; aqui va la direccion del motivo
    call WriteString
    call Crlf
    MostrarMensaje msgArchMal3
ccaFin:
    ret
CargarCatalogo ENDP

; ---- ConfirmarSalida ----
; Si hay cambios sin guardar pregunta si se quieren guardar (S/N)
; Conserva (USES): EAX, ECX, EDX
ConfirmarSalida PROC USES eax ecx edx
csRevisar:
    cmp  hayCambios, 0      ; no hay cambios, salimos
    je   csFin
    MostrarTexto msgSalirAviso
    LeerTexto bufEntrada, 80
    cmp  eax, 1         ; debe ser una sola letra
    jne  csRevisar
    mov  al, bufEntrada   ; AL = la letra
    cmp  al, 'S'
    je   csGuardar
    cmp  al, 's'
    je   csGuardar
    cmp  al, 'N'
    je   csFin
    cmp  al, 'n'
    je   csFin
    jmp  csRevisar 
csGuardar:
    call GuardarCatalogo    ; si se guarda, hayCambios queda en 0
    jmp  csRevisar
csFin:
    ret
ConfirmarSalida ENDP

END main
