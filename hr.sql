drop table alunos cascade constraints;
create table alunos (
    cod number(5) constraint alunos_cod_nn not null,
    nome varchar2(50) constraint alunos_nome_nn not null,
    status varchar2(1)  default 'C'
                        constraint alunos_status_nn not null,
    finalizado varchar2(1) default 'N' 
                        constraint alunos_finalizado_nn not null
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
    username varchar(50)   constraint usuario_username   not null,
    permissao varchar(14) constraint usuario_cargoPermi not null
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

create or replace NONEDITIONABLE TRIGGER FINALIZADO_ALUNO
BEFORE DELETE OR UPDATE ON ALUNOS
FOR EACH ROW
DECLARE
    v_permissao varchar2(1);

BEGIN
    SELECT permissao INTO v_permissao FROM usuario WHERE upper(username) = upper(user);

    IF v_permissao = 'C' AND :old.finalizado = 'S' then
        raise_application_error(-20000,'Não é possivel alterar os dados de um aluno Finalizado');
    ELSIF v_permissao = 'A' AND :old.finalizado = 'S' AND DELETING then 
        raise_application_error(-20000,'Não é possivel alterar os dados de um aluno Finalizado');
    END IF;

END;

insert into alunos (nome) values ('Roberto');

select * from alunos;

update alunos set finalizado = 'S' where cod=1;

delete alunos where cod=1;









commit;
