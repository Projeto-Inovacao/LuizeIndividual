-- Luize individual--
use nocline;
select *from VW_MEDIA_CPU_POR_LINHA_CCO;
select *from VW_MEDIA_RAM_POR_LINHA_CCO;
select *from VW_LISTAR_CCO;
select *from VW_JANELAS_CCO;


Create view VW_MEDIA_CPU_POR_LINHA_CCO as
SELECT
    linha.id_linha,
    linha.nome AS nome_linha,
    empresa.id_empresa,  -- ID da empresa
    empresa.razao_social AS nome_empresa,  -- Nome da empresa
    maquina.setor,
    AVG(monitoramento_cpu.dado_coletado) AS media_cpu,
    TIME_FORMAT(MAX(monitoramento_cpu.data_hora), '%H:%i') AS ultima_medida_hora
FROM
    linha
JOIN maquina ON linha.id_linha = maquina.fk_linhaM
JOIN empresa ON maquina.fk_empresaM = empresa.id_empresa  -- Junta a tabela empresa
LEFT JOIN VW_CPU_CHART AS monitoramento_cpu ON maquina.id_maquina = monitoramento_cpu.id_maquina
WHERE
    maquina.setor = 'CCO'
GROUP BY
    linha.id_linha, linha.nome, empresa.id_empresa, empresa.razao_social, maquina.setor;
    
-- ultimo horario de captura geral
 SELECT ultima_medida_hora
FROM VW_MEDIA_CPU_POR_LINHA_CCO
ORDER BY ultima_medida_hora DESC
LIMIT 1;


CREATE VIEW VW_MEDIA_RAM_POR_LINHA_CCO AS
SELECT
    linha.id_linha,
    linha.nome AS nome_linha,
    empresa.id_empresa,  -- ID da empresa
    empresa.razao_social AS nome_empresa,  -- Nome da empresa
    maquina.setor,
    AVG(monitoramento_ram.usado) AS media_ram,
    TIME_FORMAT(MAX(monitoramento_ram.data_hora), '%H:%i') AS ultima_medida_hora
FROM
    linha
JOIN maquina ON linha.id_linha = maquina.fk_linhaM
JOIN empresa ON maquina.fk_empresaM = empresa.id_empresa  -- Junta a tabela empresa
LEFT JOIN VW_RAM_CHART AS monitoramento_ram ON maquina.id_maquina = monitoramento_ram.id_maquina
WHERE
    maquina.setor = 'CCO'
GROUP BY
    linha.id_linha, linha.nome, empresa.id_empresa, empresa.razao_social, maquina.setor;
    
    

    
    -- View Listar
    create table VW_LISTAR_CCO as
    SELECT
  M.id_maquina,
  m.ip,
  M.hostname,
  M.so,
  M.setor,
  M.modelo,
  M.status_maquina,
  M.fk_empresaM,
  L.nome AS nome_linha,
  COUNT(DISTINCT M.id_maquina) AS qtd_maquina,
  COUNT(CASE WHEN A.tipo_alerta = 'perigo' THEN A.id_alerta END) AS qtd_perigo,
  COUNT(CASE WHEN A.tipo_alerta = 'risco' THEN A.id_alerta END) AS qtd_risco,
  COUNT(CASE WHEN A.tipo_alerta IN ('perigo', 'risco') THEN A.id_alerta END) AS qtd_alerta_maquina,
  COUNT(CASE WHEN A.data_hora BETWEEN DATE_SUB(LAST_DAY(SYSDATE()), INTERVAL 1 MONTH) AND LAST_DAY(SYSDATE()) THEN A.id_alerta END) AS qtd_alertas_no_mes
FROM
  maquina AS M
LEFT JOIN
  alerta AS A ON M.id_maquina = A.fk_maquina_alerta
LEFT JOIN
  linha AS L ON M.fk_linhaM = L.id_linha
WHERE
  M.setor = 'cco'
GROUP BY
  M.id_maquina, M.hostname, m.ip, M.so, M.modelo, M.setor, M.status_maquina, M.fk_empresaM, L.nome;


INSERT INTO  linha VALUES 
(null, "azul", 1, 1),
(null, "verde", 2, 1),
(null, "lilas", 3, 1);

-- Criar view janelas setor CCO

create view VW_JANELAS_CCO as
    SELECT
        M.id_maquina,
        M.hostname,
        COUNT(J.id_janela) AS quantidade_janelas_abertas
    FROM
        maquina AS M
    LEFT JOIN
        janela AS J ON M.id_maquina = J.fk_maquinaJ AND J.status_abertura = 1
    WHERE
        M.setor = 'CCO'
    GROUP BY
        M.id_maquina, M.hostname;
        
        
        
            
    
-- SSO
-- Criação da view para média de RAM por linha no setor 'SSO'
-- CREATE VIEW VW_MEDIA_RAM_POR_LINHA_SSO AS
-- SELECT
--     linha.id_linha,
--     linha.nome AS nome_linha,
--     empresa.id_empresa,  -- ID da empresa
--     empresa.razao_social AS nome_empresa,  -- Nome da empresa
--     maquina.setor,
--     AVG(monitoramento_ram.usado) AS media_ram,
--     TIME_FORMAT(MAX(monitoramento_ram.data_hora), '%H:%i') AS ultima_medida_hora
-- FROM
--     linha
-- JOIN maquina ON linha.id_linha = maquina.fk_linhaM
-- JOIN empresa ON maquina.fk_empresaM = empresa.id_empresa  -- Junta a tabela empresa
-- LEFT JOIN VW_RAM_CHART AS monitoramento_ram ON maquina.id_maquina = monitoramento_ram.id_maquina
-- WHERE
--     maquina.setor = 'SSO'
-- GROUP BY
--     linha.id_linha, linha.nome, empresa.id_empresa, empresa.razao_social, maquina.setor;

-- Criação da view para média de CPU por linha no setor 'SSO'
-- Create view VW_MEDIA_CPU_POR_LINHA_SSO as
-- SELECT
--     linha.id_linha,
--     linha.nome AS nome_linha,
--     empresa.id_empresa,  -- ID da empresa
--     empresa.razao_social AS nome_empresa,  -- Nome da empresa
--     maquina.setor,
--     AVG(monitoramento_cpu.dado_coletado) AS media_cpu,
--     TIME_FORMAT(MAX(monitoramento_cpu.data_hora), '%H:%i') AS ultima_medida_hora
-- FROM
--     linha
-- JOIN maquina ON linha.id_linha = maquina.fk_linhaM
-- JOIN empresa ON maquina.fk_empresaM = empresa.id_empresa  -- Junta a tabela empresa
-- LEFT JOIN VW_CPU_CHART AS monitoramento_cpu ON maquina.id_maquina = monitoramento_cpu.id_maquina
-- WHERE
--     maquina.setor = 'SSO'
-- GROUP BY
--     linha.id_linha, linha.nome, empresa.id_empresa, empresa.razao_social, maquina.setor;

-- Último horário de captura geral para a média de CPU por linha no setor 'CCO'
-- SELECT ultima_medida_hora
-- FROM VW_MEDIA_CPU_POR_LINHA_CCO
-- ORDER BY ultima_medida_hora DESC
-- LIMIT 1;



