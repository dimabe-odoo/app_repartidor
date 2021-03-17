class RutHelper {
  static String charAt(String subject, int position) {
    if (subject is! String ||
        subject.length <= position ||
        subject.length + position < 0) {
      return '';
    }

    int _realPosition = position < 0 ? subject.length + position : position;

    return subject[_realPosition];
  }

  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }

  static bool check(String rut) {
    // Despejar Puntos
    var valor = rut.replaceAll('.', '');
    // Despejar Guión
    valor = valor.replaceAll('-', '');

    var cuerpo = valor.substring(0, valor.length - 1);

    var dv = valor.substring(valor.length - 1).toUpperCase();

    if (isNumeric(cuerpo)) {
      // Este codigo fue mostrado en el hacktoberfest Concepcion 2019
      // #Hacktoberfest2019
      // Aguante el CITT <3
      // Aislar Cuerpo y Dígito Verificador

      // Formatear RUN
      rut = cuerpo + '-' + dv;

      // Si no cumple con el mínimo ej. (n.nnn.nnn)
      if (cuerpo.length < 7) {
        return false;
      }

      // Calcular Dígito Verificador
      var suma = 0;
      var multiplo = 2;

      // Para cada dígito del Cuerpo
      for (var i = 1; i <= cuerpo.length; i++) {
        // Obtener su Producto con el Múltiplo Correspondiente
        var index = multiplo * int.parse(charAt(valor, cuerpo.length - i));

        // Sumar al Contador General
        suma = suma + index;

        // Consolidar Múltiplo dentro del rango [2,7]
        if (multiplo < 7) {
          multiplo = multiplo + 1;
        } else {
          multiplo = 2;
        }
      }

      // Calcular Dígito Verificador en base al Módulo 11
      var dvEsperado = 11 - (suma % 11);

      // Casos Especiales (0 y K)
      dv = (dv == 'K') ? '10' : dv;
      dv= (dv == 0) ? '11' : dv;
      // Validar que el Cuerpo coincide con su Dígito Verificador
      if (dvEsperado.toString() != dv.toString()) {
        return false;
      }

      // Si todo sale bien, eliminar errores (decretar que es válido)
      return true;
    } else {
      return false;
    }
  }
}