drop table alunos cascade constraints;
create table alunos (
    cod number(5) not null,
    nome varchar2(50) not null,
    status varchar2(1)  default 'C' not null,
    finalizado varchar2(1) default 'N' not null
);
    
alter table alunos
add constraint pk_alunos primary key (cod);

alter table alunos
add constraint alunos_status_ck
check (status in ('C', 'A', 'R'));

alter table alunos
add constraint alunos_finalizado_ck
check (finalizado in ('S', 'N'));

drop sequence seq_alunos;
create sequence seq_alunos
    start with 1
    increment by 1
    maxvalue 99999
    minvalue 1
    ;
    
drop table usuario cascade constraints;

create table usuario (
    username varchar(50)  not null,
    permissao varchar(14) not null
);

alter table usuario
add constraint pk_usuario primary key (username);

alter table usuario
add constraint usuario_username_ck
check (username in ('HR', 'ADMIN'));

alter table usuario
add constraint usuario_cargoPermi_ck
check (permissao in ('C', 'A'));

insert into usuario values ('HR', 'C');
insert into usuario values ('ADMIN', 'A');

create or replace NONEDITIONABLE TRIGGER COD_ALUNO 
BEFORE INSERT ON ALUNOS 
FOR EACH ROW
BEGIN
  :new.cod := seq_alunos.nextval;
END;
/
create or replace NONEDITIONABLE TRIGGER FINALIZADO_ALUNO
BEFORE DELETE OR UPDATE ON ALUNOS
FOR EACH ROW
DECLARE
    v_permissao varchar2(1);

BEGIN
    SELECT permissao INTO v_permissao FROM usuario WHERE upper(username) = upper(user);

    IF v_permissao = 'C' AND :old.finalizado = 'S' then
        raise_application_error(-20000,'Não é possivel modificar os dados de um aluno Finalizado');
    ELSIF v_permissao = 'A' AND :old.finalizado = 'S' AND DELETING then 
        raise_application_error(-20000,'Não é possivel deletar os dados de um aluno Finalizado');
    END IF;

END;
/

DROP USER "ADMIN" CASCADE;
CREATE USER "ADMIN" IDENTIFIED BY "123";
GRANT SELECT, UPDATE, INSERT, DELETE ON system.alunos to ADMIN;
GRANT CREATE SESSION TO "ADMIN";

CONNECT ADMIN/123@localhost:1521/xepdb1;

insert into system.alunos (nome) values ('Roberto');
insert into system.alunos (nome) values ('Cleiton');

select * from system.alunos;

update system.alunos set finalizado = 'S' where cod=2;

delete system.alunos where cod=2;

update system.alunos set finalizado = 'N' where cod=2;

delete system.alunos where cod=2;

commit;