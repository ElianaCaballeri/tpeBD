--La fecha del primer comentario tiene que
--ser anterior a la fecha del último comentario si este no es nulo.
--TIPO TUPLA
ALTER TABLE GR02_COMENTA
ADD CONSTRAINT CK_GR02_FECHA_COMENTARIO
CHECK((fecha_ultimo_com IS NOT NULL AND fecha_primer_com<fecha_ultimo_com)OR (fecha_ultimo_com IS NULL)) ;

--SE EJECUTA CORRECTAMENTE
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(1,1,'2018-05-18','2020-06-20');
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,1,'2018-06-25','2019-03-14');
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,2,'2018-05-18','2020-11-23');
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,3,'2018-05-18',NULL);
--NO PROCEDE
--INSERT INTO GR02_COMENTA(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES(2,2,'2020-05-18','2010-04-17');

--NO PROCEDE POR QUE LA FECHA A CAMBIAR NO CUMPLE CON EL CHECKEO
--UPDATE GR02_COMENTA SET fecha_primer_com='2020-11-19' WHERE id_usuario=2 AND id_juego=1;
--PROCEDE YA QUE LA FECHA DE INICIO CUMPLE CON EL CHECKEO
--UPDATE GR02_COMENTA SET fecha_primer_com='2017-11-19' WHERE id_usuario=2 AND id_juego=1;


--Cada usuario sólo puede comentar una vez al día cada juego.
--TIPO TABLA
/*ALTER TABLE GR02_COMENTARIO
ADD CONSTRAINT CK_GR02_CANT_COMENTARIO_X_DIA
CHECK ( NOT EXISTS (SELECT 1
FROM GR02_COMENTARIO
GROUP BY ID_USUARIO,ID_JUEGO,FECHA_COMENTARIO
HAVING count(*) > 1)) ;
*/
CREATE OR REPLACE FUNCTION TRFN_GR02_fecha_comentario()
RETURNS Trigger AS $$
declare cant_comentarios Integer;
BEGIN
SELECT count(*) INTO cant_comentarios
FROM GR02_COMENTARIO
WHERE id_usuario= NEW.id_usuario AND id_juego= NEW.id_juego AND CAST(fecha_comentario AS DATE)=CAST(NEW.fecha_comentario AS DATE);

IF( cant_comentarios>=1 )THEN
RAISE EXCEPTION 'Error no puede comentar mas de 1 vez al dia por juego';
END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';


CREATE TRIGGER TR_GR02_fecha_comentario
BEFORE INSERT OR UPDATE OF fecha_comentario,id_usuario,id_juego
ON GR02_COMENTARIO
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR02_fecha_comentario();


--los insert son a prueba para demostrar que funciona la consulta interna del chequeo.
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,1,1,now(),'muy buen juego federico');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,1,2,now(),'muy buen juego federico2');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,1,3,now(),'muy buen juego federico3');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(1,1,3,'2020-11-23','muy buen juego');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,2,4,'2020-11-24','PRUEBA');
--INSERT INTO GR02_COMENTARIO(id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES(2,2,5,'2020-11-23','PRUEBAAAA2');

--UPDATE GR02_COMENTARIO SET id_juego=1 WHERE id_usuario=2 AND id_juego=2 AND id_comentario=4;
--UPDATE GR02_COMENTARIO SET id_juego=1 ,id_usuario=1 WHERE id_juego=2 AND id_usuario=2 AND id_comentario=4;


--c)Un usuario no puede recomendar un juego si no ha votado previamente dicho juego.
--TIPO GENERAL
/*CREATE ASSERTION VOTAR_ANTES_DE_RECOMENDAR
CHECK(NOT EXISTS(SELECT J.id_usuario
FROM GR02_RECOMENDACION
WHERE id_usuario,id_juego NOT IN (SELECT id_usuario,id_juego
                                   FROM GR02_VOTO)

));*/

CREATE OR REPLACE FUNCTION TRFN_GR02_RECOMENDACION_VOTO()
RETURNS Trigger AS $$
declare
BEGIN
IF NOT EXISTS(SELECT id_usuario,id_juego
FROM GR02_VOTO
WHERE id_usuario= NEW.id_usuario AND id_juego= NEW.id_juego)
THEN
RAISE EXCEPTION 'Error no puede recomendar un juego que no ha votado';
END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR02_RECOMENDACION_VOTO
BEFORE INSERT OR UPDATE OF id_usuario,id_juego
ON GR02_RECOMENDACION
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR02_RECOMENDACION_VOTO();


CREATE OR REPLACE FUNCTION TRFN_GR02_VOTO_RECOMENDACION()
RETURNS Trigger AS $$
declare
BEGIN
IF (TG_OP='UPDATE')THEN
    RAISE EXCEPTION 'Error no puede modificar un voto';
END IF;
IF (TG_OP='DELETE') THEN
    RAISE EXCEPTION 'Error no puede eliminar un voto';
END IF;
END $$
LANGUAGE 'plpgsql';


CREATE TRIGGER TR_GR02_VOTO_RECOMENDACION
BEFORE UPDATE OF id_usuario,id_juego, valor_voto OR DELETE
ON GR02_VOTO
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR02_VOTO_RECOMENDACION();

--PROCEDE
--INSERT INTO GR02_RECOMENDACION (ID_RECOMENDACION, EMAIL_RECOMENDADO, ID_USUARIO, ID_JUEGO) VALUES(1, 'elianacaballeri31@gmail.com',1,23);
--INSERT INTO GR02_JUEGA(finalizado, id_usuario, id_juego) VALUES(null,100,97);
--INSERT INTO GR02_JUEGA(finalizado, id_usuario, id_juego) VALUES(null,100,12); INSERTADO PARA EL EJEMPLO DE INSERT FALLA
--INSERT INTO GR02_VOTO(ID_VOTO,VALOR_VOTO,ID_USUARIO,ID_JUEGO) VALUES (281,5,100,97);
--INTO GR02_RECOMENDACION (ID_RECOMENDACION, EMAIL_RECOMENDADO, ID_USUARIO, ID_JUEGO) VALUES(2, 'elianacaballeri31@gmail.com',100,97);
--UPDATE gr02_recomendacion SET id_usuario=100,id_juego=26 WHERE id_usuario=100 AND id_juego=97;

--FALLA POR RESTRICCION DE TRIGGERS
--UPDATE gr02_voto SET valor_voto=7 WHERE id_usuario=100 AND id_juego=26;
--DELETE FROM gr02_voto WHERE id_usuario=98 AND id_juego=43;
--INSERT INTO GR02_RECOMENDACION (ID_RECOMENDACION, EMAIL_RECOMENDADO, ID_USUARIO, ID_JUEGO) VALUES (3,'PAUCASADO@GMIL',100,12);


--d)Un usuario no puede comentar un juego que no ha jugado.
--TIPO GENERAL
/*CREATE ASSERTION USUARIO_NO_COMENTA_JUEGO
CHECK(NOT EXISTS(SELECT 1
FROM GR02_COMENTA
WHERE (id_usuario, id_juego) IN (SELECT ID_USUARIO,ID_JUEGO
                                   FROM GR02_JUEGA )

));
*/
CREATE OR REPLACE FUNCTION TRFN_GR02_COMENTA_FIJA_JUEGA()
RETURNS Trigger AS $$
declare
BEGIN
IF NOT EXISTS(SELECT id_usuario,id_juego
    FROM GR02_JUEGA
    WHERE id_usuario= NEW.id_usuario AND id_juego= NEW.id_juego)
THEN
RAISE EXCEPTION 'Error no puede comentar un juego que no ha jugado';
END IF;
RETURN NEW;
END $$
LANGUAGE 'plpgsql';


CREATE TRIGGER TR_GR02_COMENTA_JUEGA
BEFORE INSERT OR UPDATE OF id_usuario, id_juego
ON GR02_COMENTA
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR02_COMENTA_FIJA_JUEGA();

CREATE OR REPLACE FUNCTION TRFN_GR02_JUEGA_COMENTA_ESTADOCONSISTENTE()
RETURNS Trigger AS $$
declare
BEGIN
IF(TG_OP='UPDATE') THEN
    UPDATE gr02_comenta SET id_usuario = NEW.id_usuario , id_juego = NEW.id_juego WHERE id_usuario = old.id_usuario AND id_juego = old.id_juego;
    RETURN NEW;
END IF;
IF(TG_OP='DELETE') THEN
    DELETE FROM gr02_comenta WHERE id_usuario = old.id_usuario AND id_juego = old.id_juego;
    RETURN OLD;
END IF;
END $$
LANGUAGE 'plpgsql';

CREATE TRIGGER TR_GR02_JUEGA_COMENTA
AFTER UPDATE OF id_usuario, id_juego OR DELETE
ON GR02_JUEGA
FOR EACH ROW
EXECUTE PROCEDURE TRFN_GR02_JUEGA_COMENTA_ESTADOCONSISTENTE();

--PROCEDEN
--INSERT INTO gr02_comenta (id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (1,74,'2020-11-27','2020-11-28');
--INSERT INTO gr02_comenta (id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (6,96,'2020-11-27','2020-12-27');
--INSERT INTO gr02_comenta (id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (1,74,'2020-11-27','2020-12-27');
--INSERT INTO GR02_JUEGA(finalizado, id_usuario, id_juego) VALUES(null,100,22);
--INSERT INTO gr02_comenta (id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (100,22,'2020-10-27','2020-12-27');
--UPDATE gr02_comenta SET id_juego=23 WHERE id_usuario=1 AND id_juego=74;
--UPDATE GR02_JUEGA SET id_juego=23 WHERE id_usuario=100 AND id_juego=56;
--INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (1,23,1,'2020-11-28','prueba 1');
--INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (1,74,2,'2020-11-28','prueba 2');
--DELETE FROM gr02_juega WHERE ID_USUARIO=100 AND ID_JUEGO=23;


INSERT INTO gr02_comenta (id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (100,23,'2020-10-27',null);
INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (100,23,10,'2021-11-27','prueba 3');
--INSERT INTO gr02_juego (id_juego, nombre_juego, descripcion_juego, id_categoria) VALUES (101,'MORTAL','EL MEJOR',5);

UPDATE GR02_JUEGA SET id_usuario=100, id_juego=101 WHERE id_usuario=100 AND id_juego=23;
DELETE FROM gr02_juega WHERE ID_USUARIO=100 AND ID_JUEGO=23;

--PROBAR PORQUE NO ANDA?

--FALLA
--UPDATE GR02_JUEGA SET id_juego=56 WHERE id_usuario=160 AND id_juego=23; NO HACE NADA PORQUE NO ESE JUGADOR NO JUEGA ESE JUEGO
--INSERT INTO gr02_comenta(id_usuario, id_juego, fecha_primer_com, fecha_ultimo_com) VALUES (1,76,'2020-05-23','2020-07-25');
--UPDATE gr02_comenta SET id_juego=17 WHERE id_usuario=1 AND id_juego=23;


--C) 1- Se debe mantener sincronizadas las tablas COMENTA y COMENTARIO en los siguientes aspectos:
CREATE OR REPLACE FUNCTION FN_GR02_SINCRONIZACION_COMENTA_COMENTARIO()
RETURNS Trigger AS
$$
    DECLARE
        fechadelcomentario timestamp;
        primerfecha timestamp;
        ultimafecha timestamp;
        cantidad_comentarios INTEGER;
    BEGIN
        SELECT fecha_comentario into fechadelcomentario
        FROM gr02_comentario
        WHERE id_usuario=NEW.id_usuario AND id_juego=NEW.id_juego;

        SELECT fecha_primer_com  INTO primerfecha
        FROM GR02_COMENTA
        WHERE id_usuario=NEW.id_usuario AND id_juego=NEW.id_juego;

        SELECT fecha_ultimo_com INTO ultimafecha
        FROM GR02_COMENTA
        WHERE id_usuario=NEW.id_usuario AND id_juego=NEW.id_juego;

        SELECT COUNT(*) INTO cantidad_comentarios
        FROM gr02_comentario
        WHERE id_usuario=NEW.id_usuario AND id_juego=NEW.id_juego;

        IF (cantidad_comentarios<1)THEN
            INSERT INTO GR02_COMENTA (id_usuario,id_juego, fecha_primer_com, fecha_ultimo_com)
                values (NEW.id_usuario, NEW.id_juego, NEW.fecha_comentario, NULL);
        ELSE IF ((ultimafecha is null) or (ultimafecha is not null)) THEN
            UPDATE GR02_COMENTA SET fecha_ultimo_com=NEW.fecha_comentario WHERE id_usuario=new.id_usuario AND id_juego=new.id_juego;
        END IF;
        END IF;
RETURN NEW;
END
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER TR_GR02_SINCRONIZACION_COMENTA_COMENTARIO
BEFORE INSERT OR UPDATE OF fecha_comentario
ON GR02_COMENTARIO
FOR EACH ROW
EXECUTE PROCEDURE FN_GR02_SINCRONIZACION_COMENTA_COMENTARIO();

INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (35,13,5,'2020-11-29','Esperancito');
INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (90,58,6,'2020-11-30','Dia de ñoquis');
INSERT INTO gr02_comentario (id_usuario, id_juego, id_comentario, fecha_comentario, comentario) VALUES (90,58,7,'2020-12-31','Dia de ñoquis pasados');
UPDATE gr02_comentario set fecha_comentario='2021-1-1-' where id_usuario=90 and id_juego=58 and id_comentario=7;
DELETE from gr02_comenta where id_usuario=90 and id_juego=58




