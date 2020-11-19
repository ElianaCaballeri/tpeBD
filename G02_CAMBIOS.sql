--La fecha del primer comentario tiene que
--ser anterior a la fecha del último comentario si este no es nulo.
--TIPO TUPLA
ALTER TABLE GR02_COMENTA
ADD CONSTRAINT CK_GR02_FECHA_COMENTARIO
CHECK(fecha_ultimo_com IS NOT NULL AND fecha_primer_com<fecha_ultimo_com ) ;
--SE EJECUTA CORRECTAMENTE
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(1,1,'2018-05-18','2020-06-20');

--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,1,'2018-06-25','2019-03-14');

--SI BIEN EL CAMPO PERMITE NULL EL CHECKEO NO PROCEDE POR RESTRICCION DE NULIDAD
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,2,'2018-05-18',NULL);

--NO PROCEDE
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,2,'2020-05-18','2010-04-17');

--NO PROCEDE POR QUE LA FECHA A CAMBIAR NO CUMPLE CON EL CHECKEO
--UPDATE GR02_COMENTA SET fecha_primer_com='2020-11-19' WHERE id_usuario=2 AND id_juego=1;


--PROCEDE YA QUE LA FECHA DE INICIO CUMPLE CON EL CHECKEO
--UPDATE GR02_COMENTA SET fecha_primer_com='2017-11-19' WHERE id_usuario=2 AND id_juego=1;

--VER SI HAY RESTRICCIONES PARA LOS DELETE EN LA TABLA USUARIO Y JUEGO