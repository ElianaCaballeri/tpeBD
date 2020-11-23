--La fecha del primer comentario tiene que
--ser anterior a la fecha del último comentario si este no es nulo.
--TIPO TUPLA
ALTER TABLE GR02_COMENTA
ADD CONSTRAINT CK_GR02_FECHA_COMENTARIO
CHECK((fecha_ultimo_com IS NOT NULL AND fecha_primer_com<fecha_ultimo_com)) ;
--CHECK((fecha_ultimo_com IS NOT NULL AND fecha_primer_com<fecha_ultimo_com)OR fecha_ultimo_com IS NULL ) ;
--SE EJECUTA CORRECTAMENTE
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(1,1,'2018-05-18','2020-06-20');

--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,1,'2018-06-25','2019-03-14');
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,2,'2018-05-18','2020-11-23');
--SI BIEN EL CAMPO PERMITE NULL EL CHECKEO NO PROCEDE POR RESTRICCION DE NULIDAD
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,2,'2018-05-18',NULL);

--NO PROCEDE
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,2,'2020-05-18','2010-04-17');

--NO PROCEDE POR QUE LA FECHA A CAMBIAR NO CUMPLE CON EL CHECKEO
--UPDATE GR02_COMENTA SET fecha_primer_com='2020-11-19' WHERE id_usuario=2 AND id_juego=1;


--PROCEDE YA QUE LA FECHA DE INICIO CUMPLE CON EL CHECKEO
--UPDATE GR02_COMENTA SET fecha_primer_com='2017-11-19' WHERE id_usuario=2 AND id_juego=1;

--VER SI HAY RESTRICCIONES PARA LOS DELETE EN LA TABLA USUARIO Y JUEGO


--Cada usuario sólo puede comentar una vez al día cada juego.
--TIPO TABLA
ALTER TABLE GR02_COMENTARIO
ADD CONSTRAINT CK_GR02_CANT_COMENTARIO_X_DIA
CHECK ( NOT EXISTS (SELECT 1
FROM GR02_COMENTARIO
GROUP BY ID_USUARIO,ID_JUEGO,FECHA_COMENTARIO
HAVING count(*) > 1)) ;

--los insert son a prueba para demostrar que funciona la consulta interna del chequeo.
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,1,1,'2018-06-25','muy buen juego federico');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,1,2,'2018-06-25','muy buen juego federico2');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(1,1,3,'2020-11-23','muy buen juego');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,2,4,'2020-11-23','PRUEBA');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,2,5,'2020-11-23','PRUEBAAAA2');

--UPDATE GR02_COMENTARIO SET id_juego=1 WHERE id_usuario=2 AND id_juego=2 AND id_comentario=5;
--UPDATE GR02_COMENTARIO SET id_juego=1 ,id_usuario=1 WHERE id_juego=2 AND id_usuario=2 AND id_comentario=4;


--Un usuario no puede recomendar un juego si no ha votado previamente dicho juego.
--TIPO GENERAL
CREATE ASSERTION VOTAR_ANTES_DE_RECOMENDAR
CHECK(NOT EXISTS(SELECT J.id_usuario
FROM GR02_VOTO V JOIN GR02_JUEGA J ON (V.ID_USUARIO=J.ID_USUARIO AND V.ID_JUEGO=J.ID_JUEGO )
WHERE J.ID_USUARIO,J.ID_JUEGO IN (SELECT R.ID_USUARIO,R.ID_JUEGO
                                   FROM GR02_RECOMENDACION R)

));
INSERT INTO GR02_RECOMENDACION (ID_RECOMENDACION, EMAIL_RECOMENDADO, ID_USUARIO, ID_JUEGO) VALUES(1, 'elianacaballeri31@gmail.com',1,23);
INSERT INTO GR02_RECOMENDACION (ID_RECOMENDACION, EMAIL_RECOMENDADO, ID_USUARIO, ID_JUEGO) VALUES(2, 'elianacaballeri31@gmail.com',100,97);
INSERT INTO GR02_JUEGA(finalizado, id_usuario, id_juego) VALUES(null,100,97);


--Un usuario no puede comentar un juego que no ha jugado.
--TIPO GENERAL
CREATE ASSERTION USUARIO_NO_COMENTA_JUEGO
CHECK(NOT EXISTS(SELECT J.id_usuario
FROM GR02_COMENTA C JOIN GR02_USUARIO U ON (C.ID_USUARIO=U.ID_USUARIO AND C.ID_JUEGO=U.ID_JUEGO )
WHERE U.ID_USUARIO,U.ID_JUEGO IN (SELECT J.ID_USUARIO,J.ID_JUEGO
                                   FROM GR02_JUEGA J)

));












