/* Tabla para roles */
CREATE TABLE ROL (
    ID serial PRIMARY KEY,
    Nombre varchar(30) NOT NULL UNIQUE,
    Descripcion varchar(255) NOT NULL,
    Estado bool default true /* True activo, false inactivo */    
);

/*Tabla para el manejo de clientes(incluido su log in)*/
CREATE TABLE CLIENTE (
    Cedula varchar(10) NOT NULL PRIMARY KEY, /* 0 al inicio de la cedula*/
    Usuario varchar(30) NOT NULL UNIQUE,
    Contrasena varchar(30) NOT NULL,
    Nombre varchar(30) NOT NULL,
    Apellido1 varchar(30) NOT NULL,
    Apellido2 varchar(30) NOT NULL,
    Telefono int default 0, /* si es cero se toma como que no tiene */
    Ingreso int default 0, /* si es cero se toma como que no esta registrado */
    Juridico bool default false, /* false: físico, true: juridico */
    Estado bool default true /* True activo, false inactivo */ 
    );
    
/*Tabla de localizaciones dentro del pais */
CREATE TABLE UBICACION (
    ID serial PRIMARY KEY,
    Provincia varchar (40) NOT NULL,
    Canton varchar (40) NOT NULL,
    Distrito varchar (40) NOT NULL,
    UNIQUE (Provincia, Canton, Distrito)
);
    
/* Tabla que da la dirección de un cliente */
CREATE TABLE VIVE_EN (
    IDUbicacion int NOT NULL REFERENCES UBICACION (ID),
    CedulaCliente varchar(10) NOT NULL REFERENCES CLIENTE (Cedula),
    PRIMARY KEY (IDUbicacion, CedulaCliente)
    );
/* Tabla para el manejo de cuentas del cliente */
CREATE TABLE CUENTA(
    Numero int PRIMARY KEY,
    Descripcion varchar(255) NOT NULL,
    EnDolares bool default false, /*false colones, true dolares*/
    TipoAhorro bool default true, /* true ahorro, false corriente*/
    Perteneciente varchar(10) NOT NULL REFERENCES CLIENTE (Cedula),
    Estado bool default true  /* true activo, false inactivo */
);

/*Tabla para el manejo de las tarjetas del cliente*/
CREATE TABLE TARJETA(
    Numero int PRIMARY KEY,
    Perteneciente varchar(10) NOT NULL REFERENCES CLIENTE (Cedula),
    Tipo bool default true, /*true debito, false credito*/
    FechaExpira date NOT NULL,
    CVV int NOT NULL, /* 3 digitos */
    Saldo int default 0, /* Dinero en la cuenta para debito, Disponible para credito */
    Estado bool default true /* true activo, false inactivo */
    );
   
/*Tabla para las tarjetas de debito */ 
CREATE TABLE DE_DEBITO (
    NumeroDeTarjeta int NOT NULL REFERENCES TARJETA (Numero),
   	NumeroDeCuenta int NOT NULL REFERENCES CUENTA (Numero),
    PRIMARY KEY (NumeroDeTarjeta)
);

/* Tabla para las tarjetas de credito */ 
CREATE TABLE DE_CREDITO (
    NumeroDeTarjeta int NOT NULL REFERENCES TARJETA (Numero),
    LimiteMax int default 0, /* limite maximo de credito de la tarjeta */
    Pendiente int default 0, /* balance que se debe pagar de la tarjeta */
    PRIMARY KEY (NumeroDeTarjeta)
);
    
/* Tabla paa los trabajadores, con usuario y rol */
CREATE TABLE TRABAJADOR (
    Cedula varchar(10) PRIMARY KEY,
    Usuario varchar(30) UNIQUE,
    Contrasena varchar(30) NOT NULL,
    Nombre varchar(20) NOT NULL,
    Apellido1 varchar(30) NOT NULL,
    Apellido2 varchar(30) NOT NULL,
    FechaNac date NOT NULL,
    Rol int NOT NULL REFERENCES ROL(ID),
    Estado bool default true /* true activo, false inactivo */
);
    
/*Tabla que maneja y registra la meta de cada asesor por mes */
CREATE TABLE META_ASESOR (
    Cedula varchar(10) NOT NULL REFERENCES TRABAJADOR (Cedula),
    MetaColones int default 0,
    MetaDolares int default 0,
    ActualColones int default 0,
    ActualDolares int default 0,
    FechaInicio date NOT NULL, /* fecha en la que comenzó a correr la meta */
    PRIMARY KEY (Cedula, FechaInicio)
);
    
/*Tabla que maneja los pretamos a los clientes */    
CREATE TABLE PRESTAMO (
    ID serial PRIMARY KEY,
    Cedula varchar(10) NOT NULL REFERENCES CLIENTE (Cedula),
    MontoOriginal int default 1, /* valor del monto del prestamo */
    SaldoActual int default 0, /* saldo a pagar */
    TasaInteres int default 0 /* porcentaje de interes */
);
    
/*Tabla que maneja y registra los pagos a prestamos */   
CREATE TABLE PAGO (
    IDPrestamo int NOT NULL REFERENCES PRESTAMO (ID),
    FechaDePago date NOT NULL,
    PagoOrdinario int default 0, /* monto del pago que va al ordinario (principal + intereses)*/
    PagoExtra int default 0, /* monto del pago que va al extraordinario (solo principal) */
    Estado bool default true, /* true: pendiente, false: cancelado */
    PRIMARY KEY (IDPrestamo, FechaDePago)
);
    
/*Tabla que maneja los valores de las operaciones realizadas*/
CREATE TABLE OPERACION_MOVIMIENTO (
    ID serial PRIMARY KEY,
    Monto int default 0, /* cantidad de dineroa de la operacion realizada */
    Descripcion varchar(255) NOT NULL,
    Fecha date NOT NULL,
    Origen varchar(40) NOT NULL /* Lugar donde se realizó la operación */
);

/* movimientos en la cuenta (tarjetas débito)*/
CREATE TABLE MOVIMIENTO_CUENTA (    
    NumeroDeTarjeta int NOT NULL REFERENCES DE_DEBITO (NumeroDeTarjeta), /* si fue un deposito en la sucursal se asignará a la primer tarjeta de esa cuenta*/
    Tipo int default 0, /* 0 deposito, 1 retiro, 2 compra */
    Operacion int NOT NULL REFERENCES OPERACION_MOVIMIENTO (ID),
    PRIMARY KEY (Operacion)
);

/*movimientos en tarjetas de crédito */
CREATE TABLE MOVIMIENTO_TARJETA (
    NumeroDeTarjeta int NOT NULL REFERENCES DE_CREDITO (NumeroDeTarjeta), 
    Pago bool default false, /* true: pago, false: compra */
    Operacion int NOT NULL REFERENCES OPERACION_MOVIMIENTO (ID),
    PRIMARY KEY (Operacion)
);


