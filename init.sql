-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Servidor: db
-- Tiempo de generación: 28-02-2025 a las 16:58:02
-- Versión del servidor: 11.7.2-MariaDB-ubu2404

-- Configuración inicial
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

-- Privilegios de usuario
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;

-- Creación de la base de datos
CREATE DATABASE IF NOT EXISTS `flexicoche`;
USE `flexicoche`;

-- --------------------------------------------------------
-- Estructura de tabla para la tabla `usuario`
-- --------------------------------------------------------

CREATE TABLE `usuario` (
  `correo` varchar(40) PRIMARY KEY,
  `n_documento` int(10) DEFAULT NULL,
  `nombre` varchar(30) NOT NULL,
  `apellidos` varchar(50) NOT NULL,
  `telefono` int(9) DEFAULT NULL,
  `fec_nac` date DEFAULT NULL,
  `rol` tinyint(1) DEFAULT 1,
  `foto` blob DEFAULT NULL,
  `passwd` varchar(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla para la tabla `vehiculo`
-- --------------------------------------------------------

CREATE TABLE `vehiculo` (
  `id` int(11) PRIMARY KEY NOT NULL,
  `matricula` varchar(10) NOT NULL UNIQUE,
  `combustible` enum('gasolina','diésel','híbrido no enchufable','híbrido enchufable','eléctrico') NOT NULL,
  `color` enum('negro','blanco','gris','plata','rojo','azul','verde','amarillo','naranja','marrón','dorado','púrpura','rosa','multicolor') NOT NULL,
  `precio_dia` float NOT NULL CHECK (`precio_dia` >= 0),
  `anio_matricula` date NOT NULL,
  `disponibilidad` tinyint(1) NOT NULL DEFAULT 1,
  `nombre` varchar(30) NOT NULL,
  `n_plazas` int(2) DEFAULT NULL,
  `transmision` enum('Manual','Automática','CVT','Semiautomática','Dual-Clutch') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Tablas especializadas de vehículos
-- --------------------------------------------------------

CREATE TABLE `moto` (
  `id_vehiculo` int(11) PRIMARY KEY,
  `cilindrada` int(11) NOT NULL CHECK (`cilindrada` > 0),
  `baul` tinyint(1) DEFAULT 0,
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE `coche` (
  `id_vehiculo` int(11) PRIMARY KEY,
  `carroceria` enum('Sedán','SUV','Hatchback','Coupé','Convertible','Pickup','Furgoneta','Wagon','Deportivo') NOT NULL,
  `puertas` int(11) DEFAULT 5 CHECK (`puertas` > 0),
  `potencia` int(11) NOT NULL CHECK (`potencia` > 0),
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE `furgoneta` (
  `id_vehiculo` int(11) PRIMARY KEY,
  `volumen` float DEFAULT NULL CHECK (`volumen` > 0),
  `longitud` float DEFAULT NULL CHECK (`longitud` > 0),
  `peso_max` float NOT NULL CHECK (`peso_max` > 0),
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

CREATE TABLE `camion` (
  `id_vehiculo` int(11) PRIMARY KEY,
  `peso_max` float NOT NULL CHECK (`peso_max` > 0),
  `altura` float NOT NULL CHECK (`altura` > 0),
  `n_remolques` int(11) DEFAULT 0 CHECK (`n_remolques` >= 0),
  `tipo_carga` varchar(30) DEFAULT 'General',
  `matricula_rem` varchar(10) DEFAULT NULL,
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla para la tabla `alquiler`
-- --------------------------------------------------------

CREATE TABLE `alquiler` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `id_vehiculo` int(11) NOT NULL,
  `id_usuario` varchar(40) NOT NULL,
  `estado` enum('a pagar','procesando','denegado','en alquiler','devuelto','retraso') NOT NULL DEFAULT 'a pagar',
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`),
  FOREIGN KEY (`id_usuario`) REFERENCES `usuario`(`correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla para la tabla `factura`
-- --------------------------------------------------------

CREATE TABLE `factura` (
  `id` int(11) PRIMARY KEY AUTO_INCREMENT,
  `id_alquiler` int(11) NOT NULL UNIQUE,
  `importe` float NOT NULL CHECK (`importe` >= 0),
  FOREIGN KEY (`id_alquiler`) REFERENCES `alquiler`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Estructura de tabla para la tabla `imagen`
-- --------------------------------------------------------

CREATE TABLE `imagen` (
  `id_vehiculo` int(11) NOT NULL,
  `imagen` blob NOT NULL,
  FOREIGN KEY (`id_vehiculo`) REFERENCES `vehiculo`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_uca1400_ai_ci;

-- --------------------------------------------------------
-- Disparadores
-- --------------------------------------------------------

DELIMITER $$
CREATE TRIGGER `check_fec_nac_usuario` BEFORE INSERT ON `usuario`
FOR EACH ROW BEGIN
    IF NEW.fec_nac > CURDATE() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fecha de nacimiento no válida';
    END IF;
END$$

CREATE TRIGGER `check_fechas_alquiler` BEFORE INSERT ON `alquiler`
FOR EACH ROW BEGIN
    IF NEW.fecha_inicio > NEW.fecha_fin THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Fecha inicio debe ser anterior a fecha fin';
    END IF;
END$$
DELIMITER ;

-- --------------------------------------------------------
-- Inserts de datos
-- --------------------------------------------------------

-- Usuarios
INSERT INTO `usuario` (`correo`, `n_documento`, `nombre`, `apellidos`, `telefono`, `fec_nac`, `rol`, `passwd`) VALUES
('admin@flexicoche.com', 12345678, 'Admin', 'Sistema', 600000000, '1990-01-01', 1, 'admin123'),
('mario.moreno@email.com', 10123457, 'Mario', 'Moreno Romero', 612345687, '1983-12-18', 1, 'contraseña117'),
('carlos.garcia@email.com', 12345678, 'Carlos', 'García Pérez', 612345678, '1985-03-10', 0, 'contraseña123'),
('ana.martinez@email.com', 23456789, 'Ana', 'Martínez Sánchez', 612345679, '1990-07-22', 0, 'contraseña456'),
('juan.rodriguez@email.com', 34567890, 'Juan', 'Rodríguez López', 612345680, '1982-01-15', 0, 'contraseña789'),
('laura.fernandez@email.com', 45678901, 'Laura', 'Fernández Gómez', 612345681, '1995-11-25', 0, 'contraseña101'),
('jose.lopez@email.com', 56789012, 'José', 'López Ruiz', 612345682, '1979-02-14', 0, 'contraseña112'),
('pedro.sanchez@email.com', 67890123, 'Pedro', 'Sánchez Martínez', 612345683, '1988-08-30', 0, 'contraseña113'),
('marta.gonzalez@email.com', 78901234, 'Marta', 'González García', 612345684, '1992-06-05', 0, 'contraseña114'),
('david.alvarez@email.com', 89012345, 'David', 'Álvarez Díaz', 612345685, '1980-04-20', 0, 'contraseña115');

-- Vehículos
INSERT INTO `vehiculo` (`id`, `matricula`, `combustible`, `color`, `precio_dia`, `anio_matricula`, `disponibilidad`, `nombre`, `n_plazas`, `transmision`) VALUES
(1, '1234ABC', 'gasolina', 'rojo', 50.0, '2018-04-15', 1, 'Ford Focus', 5, 'Automática'),
(2, '2345DEF', 'diésel', 'blanco', 60.0, '2020-07-10', 1, 'Volkswagen Golf', 5, 'Manual'),
(3, '3456GHI', 'híbrido enchufable', 'azul', 70.0, '2022-01-20', 1, 'Toyota Prius', 5, 'CVT'),
(4, '4567JKL', 'gasolina', 'negro', 80.0, '2021-08-10', 1, 'Honda CB500', 2, 'Manual'),
(5, '5678MNO', 'diésel', 'plata', 55.0, '2017-06-12', 1, 'Kawasaki Ninja', 2, 'Manual'),
(6, '6789PQR', 'híbrido no enchufable', 'rojo', 65.0, '2020-09-15', 1, 'Yamaha MT-07', 2, 'Semiautomática'),
(7, '7890STU', 'gasolina', 'gris', 70.0, '2023-02-02', 1, 'Renault Master', 3, 'Manual'),
(8, '8901VWX', 'diésel', 'amarillo', 85.0, '2019-11-11', 1, 'Mercedes-Benz Vito', 3, 'Automática'),
(9, '9012XYZ', 'gasolina', 'verde', 75.0, '2022-03-22', 1, 'Ford Transit', 3, 'Manual'),
(10, '1234ZZZ', 'híbrido no enchufable', 'marrón', 100.0, '2021-04-10', 1, 'Scania R500', 2, 'Manual');

-- Coches
INSERT INTO `coche` (`id_vehiculo`, `carroceria`, `puertas`, `potencia`) VALUES
(1, 'Sedán', 4, 150),
(2, 'Hatchback', 5, 180),
(3, 'Sedán', 4, 120);

-- Motos
INSERT INTO `moto` (`id_vehiculo`, `cilindrada`, `baul`) VALUES
(4, 500, 0),
(5, 600, 0),
(6, 700, 0);

-- Furgonetas
INSERT INTO `furgoneta` (`id_vehiculo`, `volumen`, `longitud`, `peso_max`) VALUES
(7, 18, 6.2, 3500),
(8, 20, 6.5, 3700),
(9, 22, 7.0, 4000);

-- Camiones
INSERT INTO `camion` (`id_vehiculo`, `peso_max`, `altura`, `n_remolques`, `tipo_carga`, `matricula_rem`) VALUES
(10, 18000, 4.5, 1, 'Carga general', 'AB1234CD');

-- Alquileres
INSERT INTO `alquiler` (`id_vehiculo`, `id_usuario`, `estado`, `fecha_inicio`, `fecha_fin`) VALUES
(1, 'mario.moreno@email.com', 'en alquiler', '2025-02-01', '2025-02-05'),
(2, 'carlos.garcia@email.com', 'a pagar', '2025-02-02', '2025-02-06'),
(3, 'ana.martinez@email.com', 'procesando', '2025-02-03', '2025-02-07');

-- Facturas
INSERT INTO `factura` (`id_alquiler`, `importe`) VALUES
(1, 250.0),
(2, 300.0),
(3, 280.0);

-- Finalización
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;