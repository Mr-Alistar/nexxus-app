//Este archivo contiene las opciones para los campos de opción múltiple del formulario.
//IMPORTANTE: los nombres de Género, Carrera, Modalidad y Preparatoria deben
//coincidir EXACTAMENTE con el catálogo del CRM Nexxus (tablas generos, carreras,
//modalidades, preparatorias), porque la API los resuelve por nombre.

//Género (catálogo CRM: generos)
const List<String> opcionesGenero = ["Hombre", "Mujer", "Otro"];

//Tipo de zona (texto libre, se guarda tal cual en el CRM)
const List<String> opcionesTipoZona = [
  "Urbana (ciudad)",
  "Rural (poblado)",
  "Extranjero"
];

//Carreras de la UT (catálogo CRM: carreras — nombres oficiales)
const List<String> opcionesCarrera = [
  "Licenciatura en Gastronomía",
  "Ingeniería en Datos e Inteligencia Artificial",
  "Ingeniería en Mecatrónica",
  "Ingeniería Financiera",
  "Ingeniería en Tecnologías de la Información e Innovación Digital",
  "Licenciatura en Innovación de Negocios y Mercadotecnia"
];

//Modalidades (catálogo CRM: modalidades)
const List<String> opcionesModalidad = ["Escolarizada", "Mixta", "PEESAD"];

//Preparatoria (catálogo CRM: preparatorias). "Otro" permite texto libre:
//la API lo guarda en el campo preparatoria_otro si no coincide con el catálogo.
const List<String> opcionesPreparatoria = [
  "Eva Sámano De López Mateos",
  "Colegio De Bachilleres Uno",
  "Colegio De Bachilleres Dos",
  "Cbtis 253",
  "Cbta 11",
  "Cecyte",
  "Cetmar",
  "Conalep",
  "Cbtis 214",
  "Instituto Cumbres",
  "Instituto Modelo",
  "Instituto LAMAT",
  "Instituto Educativo WOSNIAK",
  "Centro Educativo Ignacio López Rayón",
  "Telebachillerato Manuel Ávila Camacho",
  "Telebachillerato Ramonal",
  "Telebachillerato Buenavista",
  "Telebachillerato Pantera",
  "Telebachillerato Polyuc",
  "Emsad Chunhuhub",
  "Emsad Vallehermoso",
  "Colegio de Bachilleres Nicolás Bravo",
  "Telebachillerato Francisco Villa",
  "Telebachillerato González Ortega",
  "Telebachillerato Sergio Butrón Casas",
  "Colegios de bachilleres Carlos A Madrazo",
  "Telebachillerato Huay Pix",
  "Colegio de Bachilleres Río Hondo",
  "Telebachillerato Allende",
  "Telebachillerato Juan Sarabia",
  "Emsad Colegio de Bachilleres Mahahual",
  "Emsad Colegio de Bachilleres Limones",
  "Colegio de Bachilleres Bacalar",
  "Otro"
];

//Medio enterado (texto libre, se guarda tal cual en el CRM)
const List<String> opcionesMedioEnterado = [
  "Facebook",
  "Instagram",
  "Radio",
  "Recomendación",
  "Feria universitaria"
];
