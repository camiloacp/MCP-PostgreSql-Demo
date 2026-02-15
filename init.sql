-- =============================================================
-- MCP Demo: Script de inicializacion de base de datos
-- Se ejecuta automaticamente al crear el contenedor PostgreSQL
-- =============================================================

-- ─── TABLAS ─────────────────────────────────────────────────

CREATE TABLE empleados (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    departamento VARCHAR(50) NOT NULL,
    salario NUMERIC(10,2) NOT NULL,
    fecha_ingreso DATE NOT NULL,
    activo BOOLEAN DEFAULT true
);

CREATE TABLE vacaciones (
    id SERIAL PRIMARY KEY,
    empleado_id INTEGER NOT NULL REFERENCES empleados(id),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado VARCHAR(20) NOT NULL CHECK (estado IN ('pendiente', 'aprobada', 'rechazada')),
    motivo VARCHAR(200)
);

CREATE TABLE evaluaciones (
    id SERIAL PRIMARY KEY,
    empleado_id INTEGER NOT NULL REFERENCES empleados(id),
    fecha DATE NOT NULL,
    puntuacion INTEGER NOT NULL CHECK (puntuacion BETWEEN 1 AND 10),
    comentario TEXT,
    evaluador_id INTEGER REFERENCES empleados(id)
);

CREATE TABLE capacitaciones (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT,
    duracion_horas INTEGER NOT NULL,
    fecha DATE NOT NULL
);

CREATE TABLE empleados_capacitaciones (
    id SERIAL PRIMARY KEY,
    empleado_id INTEGER NOT NULL REFERENCES empleados(id),
    capacitacion_id INTEGER NOT NULL REFERENCES capacitaciones(id),
    completada BOOLEAN DEFAULT false,
    nota NUMERIC(4,2),
    UNIQUE(empleado_id, capacitacion_id)
);

-- ─── DATOS: EMPLEADOS (110 registros) ──────────────────────

INSERT INTO empleados (nombre, apellido, email, departamento, salario, fecha_ingreso, activo) VALUES
('Carlos',    'Garcia',      'carlos.garcia@empresa.com',       'Ingenieria',       4500.00, '2022-03-15', true),
('Maria',     'Lopez',       'maria.lopez@empresa.com',         'Marketing',        3800.00, '2021-07-20', true),
('Juan',      'Martinez',    'juan.martinez@empresa.com',       'Ingenieria',       5200.00, '2020-01-10', true),
('Ana',       'Rodriguez',   'ana.rodriguez@empresa.com',       'Recursos Humanos', 3500.00, '2023-05-01', true),
('Pedro',     'Sanchez',     'pedro.sanchez@empresa.com',       'Ventas',           4100.00, '2021-11-30', true),
('Laura',     'Fernandez',   'laura.fernandez@empresa.com',     'Ingenieria',       4800.00, '2022-09-12', true),
('Diego',     'Torres',      'diego.torres@empresa.com',        'Marketing',        3600.00, '2023-02-28', false),
('Sofia',     'Ramirez',     'sofia.ramirez@empresa.com',       'Ventas',           4300.00, '2020-06-15', true),
('Miguel',    'Herrera',     'miguel.herrera@empresa.com',      'Ingenieria',       5500.00, '2019-08-22', true),
('Valentina', 'Diaz',        'valentina.diaz@empresa.com',      'Recursos Humanos', 3700.00, '2023-10-05', true),
('Alejandro', 'Ruiz',        'alejandro.ruiz@empresa.com',      'Finanzas',         4600.00, '2021-02-14', true),
('Beatriz',   'Gomez',       'beatriz.gomez@empresa.com',       'Marketing',        3950.00, '2022-06-10', true),
('Camilo',    'Vargas',      'camilo.vargas@empresa.com',       'Ingenieria',       5100.00, '2020-11-05', true),
('Daniela',   'Castro',      'daniela.castro@empresa.com',      'Recursos Humanos', 3550.00, '2023-01-15', true),
('Eduardo',   'Morales',     'eduardo.morales@empresa.com',     'Ventas',           4200.00, '2021-09-22', true),
('Fernanda',  'Ortega',      'fernanda.ortega@empresa.com',     'Ingenieria',       4950.00, '2022-04-18', true),
('Gabriel',   'Delgado',     'gabriel.delgado@empresa.com',     'Soporte',          3200.00, '2023-08-30', true),
('Hector',    'Romero',      'hector.romero@empresa.com',       'Ventas',           4050.00, '2019-12-12', false),
('Isabel',    'Navarro',     'isabel.navarro@empresa.com',      'Marketing',        3750.00, '2021-05-25', true),
('Javier',    'Mendoza',     'javier.mendoza@empresa.com',      'Finanzas',         5300.00, '2020-03-08', true),
('Karla',     'Rios',        'karla.rios@empresa.com',          'Ingenieria',       4700.00, '2022-11-11', true),
('Luis',      'Silva',       'luis.silva@empresa.com',           'Operaciones',      3400.00, '2023-03-03', true),
('Monica',    'Rojas',       'monica.rojas@empresa.com',        'Recursos Humanos', 3650.00, '2021-08-19', true),
('Nicolas',   'Cruz',        'nicolas.cruz@empresa.com',        'Ventas',           4400.00, '2020-07-07', true),
('Olivia',    'Reyes',       'olivia.reyes@empresa.com',        'Ingenieria',       5400.00, '2019-10-29', true),
('Pablo',     'Gutierrez',   'pablo.gutierrez@empresa.com',     'Soporte',          3100.00, '2023-06-14', true),
('Quintin',   'Perez',       'quintin.perez@empresa.com',       'Marketing',        3850.00, '2022-02-02', false),
('Rosa',      'Aguilar',     'rosa.aguilar@empresa.com',        'Finanzas',         4750.00, '2021-01-20', true),
('Santiago',  'Pina',        'santiago.pina@empresa.com',       'Ingenieria',       5000.00, '2020-09-15', true),
('Teresa',    'Vega',        'teresa.vega@empresa.com',         'Recursos Humanos', 3600.00, '2023-04-10', true),
('Ulises',    'Soto',        'ulises.soto@empresa.com',         'Ventas',           4150.00, '2021-12-05', true),
('Veronica',  'Cabrera',     'veronica.cabrera@empresa.com',    'Marketing',        3900.00, '2022-08-22', true),
('Walter',    'Ibarra',      'walter.ibarra@empresa.com',       'Ingenieria',       5250.00, '2019-05-30', true),
('Ximena',    'Nunez',       'ximena.nunez@empresa.com',        'Finanzas',         4550.00, '2020-02-17', true),
('Yolanda',   'Flores',      'yolanda.flores@empresa.com',      'Operaciones',      3350.00, '2023-09-09', true),
('Zacarias',  'Acosta',      'zacarias.acosta@empresa.com',     'Ventas',           4250.00, '2021-06-18', true),
('Andres',    'Medina',      'andres.medina@empresa.com',       'Ingenieria',       4850.00, '2022-05-05', true),
('Bianca',    'Suarez',      'bianca.suarez@empresa.com',       'Recursos Humanos', 3720.00, '2023-07-21', true),
('Cesar',     'Castillo',    'cesar.castillo@empresa.com',      'Marketing',        3880.00, '2021-11-11', true),
('Diana',     'Pacheco',     'diana.pacheco@empresa.com',       'Finanzas',         4650.00, '2020-04-04', true),
('Esteban',   'Vazquez',     'esteban.vazquez@empresa.com',     'Ingenieria',       5150.00, '2019-09-28', true),
('Fabiola',   'Leon',        'fabiola.leon@empresa.com',        'Soporte',          3150.00, '2023-10-10', true),
('Gustavo',   'Serrano',     'gustavo.serrano@empresa.com',     'Ventas',           4350.00, '2021-03-15', true),
('Hilda',     'Cortes',      'hilda.cortes@empresa.com',        'Operaciones',      3450.00, '2022-12-01', true),
('Ignacio',   'Salazar',     'ignacio.salazar@empresa.com',     'Ingenieria',       4900.00, '2020-08-08', false),
('Juana',     'Molina',      'juana.molina@empresa.com',        'Recursos Humanos', 3680.00, '2023-02-20', true),
('Kevin',     'Arroyo',      'kevin.arroyo@empresa.com',       'Marketing',        3920.00, '2021-10-31', true),
('Lorena',    'Miranda',     'lorena.miranda@empresa.com',      'Finanzas',         4800.00, '2020-01-25', true),
('Mario',     'Campos',      'mario.campos@empresa.com',        'Ingenieria',       5350.00, '2019-11-19', true),
('Natalia',   'Valenzuela',  'natalia.valenzuela@empresa.com',  'Ventas',           4120.00, '2022-03-03', true),
('Oscar',     'Bautista',    'oscar.bautista@empresa.com',      'Soporte',          3250.00, '2023-05-15', true),
('Patricia',  'Cardenas',    'patricia.cardenas@empresa.com',   'Ingenieria',       4780.00, '2021-07-29', true),
('Roberto',   'Orozco',      'roberto.orozco@empresa.com',      'Marketing',        3780.00, '2022-09-09', false),
('Silvia',    'Barrera',     'silvia.barrera@empresa.com',      'Recursos Humanos', 3580.00, '2023-11-25', true),
('Tomas',     'Zamora',      'tomas.zamora@empresa.com',        'Finanzas',         4720.00, '2020-06-16', true),
('Ursula',    'Fuentes',     'ursula.fuentes@empresa.com',      'Ventas',           4300.00, '2021-04-12', true),
('Victor',    'Valencia',    'victor.valencia@empresa.com',     'Ingenieria',       5050.00, '2019-12-22', true),
('Wendy',     'Cervantes',   'wendy.cervantes@empresa.com',     'Operaciones',      3380.00, '2023-01-30', true),
('Xavier',    'Tapia',       'xavier.tapia@empresa.com',        'Marketing',        3980.00, '2022-07-07', true),
('Yair',      'Salinas',     'yair.salinas@empresa.com',        'Ingenieria',       4920.00, '2020-10-20', true),
('Zoe',       'Pineda',      'zoe.pineda@empresa.com',          'Finanzas',         4680.00, '2021-09-01', true),
('Adrian',    'Mejia',       'adrian.mejia@empresa.com',        'Ventas',           4220.00, '2022-04-14', true),
('Brenda',    'Solis',       'brenda.solis@empresa.com',        'Recursos Humanos', 3620.00, '2023-08-05', true),
('Cristian',  'Villanueva',  'cristian.villanueva@empresa.com', 'Ingenieria',       5450.00, '2019-07-17', true),
('Delia',     'Montes',      'delia.montes@empresa.com',        'Soporte',          3050.00, '2023-12-12', true),
('Enrique',   'Escobar',     'enrique.escobar@empresa.com',     'Marketing',        3820.00, '2021-02-28', true),
('Fatima',    'Gallegos',    'fatima.gallegos@empresa.com',     'Finanzas',         4880.00, '2020-05-21', true),
('Gerardo',   'Roman',       'gerardo.roman@empresa.com',       'Ingenieria',       5120.00, '2022-01-15', true),
('Helena',    'Lara',        'helena.lara@empresa.com',         'Ventas',           4450.00, '2021-08-30', false),
('Ivan',      'Peralta',     'ivan.peralta@empresa.com',        'Operaciones',      3420.00, '2023-03-25', true),
('Julia',     'Espinoza',    'julia.espinoza@empresa.com',      'Recursos Humanos', 3660.00, '2022-06-18', true),
('Karim',     'Velasco',     'karim.velasco@empresa.com',       'Ingenieria',       4980.00, '2020-11-29', true),
('Lidia',     'Maldonado',   'lidia.maldonado@empresa.com',     'Marketing',        3940.00, '2021-12-10', true),
('Manuel',    'Rosales',     'manuel.rosales@empresa.com',      'Finanzas',         4620.00, '2019-08-08', true),
('Nora',      'Villarreal',  'nora.villarreal@empresa.com',     'Ventas',           4180.00, '2022-10-02', true),
('Omar',      'De la Rosa',  'omar.delarosa@empresa.com',       'Ingenieria',       5220.00, '2020-03-14', true),
('Paula',     'Beltran',     'paula.beltran@empresa.com',       'Soporte',          3180.00, '2023-06-20', true),
('Quique',    'Andrade',     'quique.andrade@empresa.com',      'Marketing',        3860.00, '2021-05-15', true),
('Raquel',    'Barajas',     'raquel.barajas@empresa.com',      'Recursos Humanos', 3740.00, '2023-09-28', true),
('Samuel',    'Davila',      'samuel.davila@empresa.com',       'Finanzas',         4760.00, '2020-12-05', true),
('Tania',     'Guzman',      'tania.guzman@empresa.com',        'Ingenieria',       4860.00, '2022-03-22', true),
('Uriel',     'Padilla',     'uriel.padilla@empresa.com',       'Ventas',           4280.00, '2021-07-11', true),
('Vanesa',    'Arellano',    'vanesa.arellano@empresa.com',     'Operaciones',      3480.00, '2023-02-14', true),
('William',   'Ponce',       'william.ponce@empresa.com',       'Marketing',        3960.00, '2022-08-01', true),
('Ximena',    'Cisneros',    'ximena.cisneros@empresa.com',     'Ingenieria',       5320.00, '2019-06-30', true),
('Yahir',     'Olivares',    'yahir.olivares@empresa.com',      'Finanzas',         4820.00, '2020-09-19', true),
('Zara',      'Galvan',      'zara.galvan@empresa.com',         'Recursos Humanos', 3690.00, '2023-11-05', true),
('Alfonso',   'Corona',      'alfonso.corona@empresa.com',      'Ventas',           4320.00, '2021-01-28', true),
('Berta',     'Hurtado',     'berta.hurtado@empresa.com',       'Soporte',          3120.00, '2023-07-15', true),
('Carlos',    'Montoya',     'carlos.montoya@empresa.com',      'Ingenieria',       5080.00, '2020-02-25', false),
('Dalia',     'Palacios',    'dalia.palacios@empresa.com',      'Marketing',        3840.00, '2022-05-19', true),
('Elias',     'Rico',        'elias.rico@empresa.com',          'Finanzas',         4690.00, '2019-10-10', true),
('Flor',      'Mata',        'flor.mata@empresa.com',           'Operaciones',      3410.00, '2023-04-25', true),
('Guillermo', 'Lozano',      'guillermo.lozano@empresa.com',    'Ingenieria',       4960.00, '2021-11-20', true),
('Hanna',     'Cano',        'hanna.cano@empresa.com',          'Recursos Humanos', 3710.00, '2023-01-05', true),
('Ismael',    'Ochoa',       'ismael.ochoa@empresa.com',        'Ventas',           4260.00, '2022-06-30', true),
('Jazmin',    'Benitez',     'jazmin.benitez@empresa.com',      'Marketing',        3910.00, '2021-09-14', true),
('Katia',     'Trevino',     'katia.trevino@empresa.com',       'Finanzas',         4780.00, '2020-05-08', true),
('Leo',       'Zavala',      'leo.zavala@empresa.com',           'Ingenieria',       5420.00, '2019-12-15', true),
('Mireya',    'Noriega',     'mireya.noriega@empresa.com',      'Soporte',          3220.00, '2023-08-22', true),
('Noe',       'Carrillo',    'noe.carrillo@empresa.com',        'Ventas',           4380.00, '2021-03-27', true),
('Olga',      'Escamilla',   'olga.escamilla@empresa.com',      'Recursos Humanos', 3640.00, '2022-10-18', true),
('Paco',      'Alvarado',    'paco.alvarado@empresa.com',       'Ingenieria',       5180.00, '2020-07-23', true),
('Quetzal',   'Duran',       'quetzal.duran@empresa.com',       'Marketing',        3990.00, '2021-12-02', true),
('Ramiro',    'Cordero',     'ramiro.cordero@empresa.com',      'Finanzas',         4850.00, '2019-09-05', true),
('Sara',      'Becerra',     'sara.becerra@empresa.com',        'Operaciones',      3460.00, '2023-05-30', false),
('Tito',      'Murillo',     'tito.murillo@empresa.com',        'Ventas',           4240.00, '2022-02-12', true),
('Ulrich',    'Villegas',    'ulrich.villegas@empresa.com',     'Ingenieria',       5020.00, '2020-08-25', true),
('Valeria',   'Garza',       'valeria.garza@empresa.com',       'Recursos Humanos', 3760.00, '2023-11-15', true),
('Wilfredo',  'Reyna',       'wilfredo.reyna@empresa.com',      'Marketing',        3870.00, '2021-06-06', true);

-- ─── DATOS: VACACIONES (20 registros) ──────────────────────

INSERT INTO vacaciones (empleado_id, fecha_inicio, fecha_fin, estado, motivo) VALUES
(1,  '2025-01-10', '2025-01-20', 'aprobada',  'Vacaciones familiares'),
(1,  '2025-07-01', '2025-07-15', 'aprobada',  'Viaje a Europa'),
(2,  '2025-03-05', '2025-03-12', 'aprobada',  'Descanso personal'),
(3,  '2025-06-15', '2025-06-25', 'pendiente', 'Mudanza'),
(4,  '2025-02-01', '2025-02-10', 'aprobada',  'Viaje familiar'),
(5,  '2025-04-20', '2025-04-30', 'rechazada', 'Temporada alta de ventas'),
(6,  '2025-08-01', '2025-08-14', 'aprobada',  'Vacaciones de verano'),
(7,  '2025-05-10', '2025-05-17', 'aprobada',  'Evento personal'),
(8,  '2025-09-01', '2025-09-10', 'pendiente', 'Descanso'),
(10, '2025-03-20', '2025-03-28', 'aprobada',  'Viaje'),
(12, '2025-06-01', '2025-06-10', 'aprobada',  'Conferencia + descanso'),
(15, '2025-11-15', '2025-11-25', 'pendiente', 'Fin de ano'),
(20, '2025-04-01', '2025-04-08', 'aprobada',  'Tramites personales'),
(25, '2025-07-20', '2025-07-30', 'aprobada',  'Vacaciones'),
(30, '2025-10-05', '2025-10-15', 'pendiente', 'Viaje familiar'),
(35, '2025-12-20', '2025-12-31', 'pendiente', 'Fiestas'),
(40, '2025-02-14', '2025-02-21', 'aprobada',  'Descanso'),
(45, '2025-05-01', '2025-05-10', 'rechazada', 'Proyecto en curso'),
(50, '2025-08-15', '2025-08-25', 'aprobada',  'Vacaciones familiares'),
(55, '2025-09-20', '2025-09-30', 'aprobada',  'Viaje al exterior');

-- ─── DATOS: EVALUACIONES (25 registros, 2 rondas) ─────────

INSERT INTO evaluaciones (empleado_id, fecha, puntuacion, comentario, evaluador_id) VALUES
-- Ronda enero 2025
(1,  '2025-01-15', 9,  'Excelente rendimiento tecnico, lidera bien el equipo', 3),
(2,  '2025-01-15', 8,  'Muy buenas campanas, cumple objetivos', 7),
(3,  '2025-01-15', 7,  'Buen trabajo, puede mejorar en documentacion', 1),
(4,  '2025-01-15', 8,  'Gestion impecable de procesos internos', 10),
(5,  '2025-01-15', 6,  'Cumple metas pero falta proactividad', 8),
(6,  '2025-01-15', 9,  'Resuelve problemas complejos rapidamente', 1),
(7,  '2025-01-15', 7,  'Creativo, necesita mejorar plazos de entrega', 2),
(8,  '2025-01-15', 8,  'Buen cierre de ventas, excelente trato al cliente', 5),
(9,  '2025-01-15', 10, 'Rendimiento excepcional en todos los frentes', 1),
(10, '2025-01-15', 7,  'Consistente, buen manejo de conflictos', 4),
(11, '2025-01-15', 8,  'Analisis financiero preciso y oportuno', 20),
(15, '2025-01-15', 7,  'Buen desempeno en ventas regionales', 5),
(20, '2025-01-15', 9,  'Liderazgo en reportes financieros', 11),
(25, '2025-01-15', 8,  'Gran capacidad de resolucion', 1),
(30, '2025-01-15', 6,  'Necesita mejorar comunicacion con el equipo', 4),
-- Ronda julio 2025
(1,  '2025-07-15', 10, 'Supero todas las expectativas del semestre', 3),
(2,  '2025-07-15', 8,  'Mantuvo buen nivel, campana de verano exitosa', 7),
(3,  '2025-07-15', 8,  'Mejoro significativamente en documentacion', 1),
(5,  '2025-07-15', 7,  'Mejoro en proactividad, buen progreso', 8),
(6,  '2025-07-15', 9,  'Sigue siendo referente tecnico del equipo', 1),
(9,  '2025-07-15', 9,  'Consistentemente excelente', 1),
(10, '2025-07-15', 8,  'Mejoro en comunicacion, buena gestion', 4),
(15, '2025-07-15', 8,  'Supero metas de ventas Q2', 5),
(20, '2025-07-15', 9,  'Implemento mejoras en reportes', 11),
(25, '2025-07-15', 9,  'Lidero proyecto critico con exito', 1);

-- ─── DATOS: CAPACITACIONES (8 cursos) ──────────────────────

INSERT INTO capacitaciones (nombre, descripcion, duracion_horas, fecha) VALUES
('Python Avanzado',             'Decoradores, generadores, async/await y patrones de diseno',  40, '2025-02-01'),
('Liderazgo y Gestion',        'Habilidades de liderazgo para mandos medios',                  24, '2025-03-15'),
('SQL y Bases de Datos',        'Optimizacion de queries, indices y modelado relacional',       32, '2025-04-10'),
('Marketing Digital',           'SEO, SEM, redes sociales y metricas de conversion',            28, '2025-05-01'),
('Seguridad Informatica',       'OWASP Top 10, pentesting basico y buenas practicas',           36, '2025-06-01'),
('Comunicacion Efectiva',       'Tecnicas de presentacion y comunicacion asertiva',              16, '2025-07-01'),
('Excel y Analisis de Datos',   'Tablas dinamicas, macros y visualizacion de datos',             20, '2025-08-15'),
('Scrum y Metodologias Agiles', 'Roles, ceremonias, artefactos y metricas agiles',               24, '2025-09-01');

-- ─── DATOS: EMPLEADOS <-> CAPACITACIONES (45 asignaciones) ─

INSERT INTO empleados_capacitaciones (empleado_id, capacitacion_id, completada, nota) VALUES
-- Python Avanzado (ingenieros)
(1,  1, true,  9.50), (3,  1, true,  8.00), (6,  1, true,  9.00), (9,  1, true,  10.00),
(13, 1, true,  7.50), (16, 1, false, NULL),  (25, 1, true,  8.50), (29, 1, true,  7.00),
-- Liderazgo y Gestion (mix)
(1,  2, true,  8.00), (4,  2, true,  9.00), (10, 2, true,  7.50), (20, 2, true,  8.50),
(30, 2, false, NULL),
-- SQL y Bases de Datos (varios)
(1,  3, true,  9.00), (3,  3, true,  8.50), (11, 3, true,  9.00), (20, 3, true,  9.50),
(25, 3, true,  8.00), (40, 3, false, NULL),
-- Marketing Digital
(2,  4, true,  8.50), (7,  4, true,  9.00), (12, 4, true,  7.50), (19, 4, true,  8.00),
(27, 4, false, NULL),
-- Seguridad Informatica
(1,  5, true,  9.00), (6,  5, true,  9.50), (9,  5, true,  8.50), (17, 5, true,  8.00),
(26, 5, true,  7.50),
-- Comunicacion Efectiva (RRHH y otros)
(4,  6, true,  9.00), (10, 6, true,  8.50), (14, 6, true,  8.00), (23, 6, false, NULL),
(30, 6, true,  7.00),
-- Excel y Analisis de Datos (finanzas y otros)
(11, 7, true,  9.50), (20, 7, true,  9.00), (28, 7, true,  8.00), (34, 7, true,  8.50),
(40, 7, true,  7.50),
-- Scrum y Metodologias Agiles (ingenieros + marketing)
(1,  8, true,  8.50), (3,  8, true,  8.00), (6,  8, true,  9.00), (2,  8, true,  7.50),
(7,  8, false, NULL),  (13, 8, true,  8.00);
