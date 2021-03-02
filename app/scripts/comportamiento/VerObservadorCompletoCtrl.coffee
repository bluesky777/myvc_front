angular.module('myvcFrontApp')

.controller('VerObservadorCompletoCtrl', ['$scope', 'toastr', 'grupo', 'App', 'Perfil', ($scope, toastr, grupo, App, Perfil)->
  $scope.grupo      = grupo.data.grupo;
  $scope.imagenes   = grupo.data.imagenes;
  
  $scope.views 			= App.views
  
  $scope.observ 		= {
    encabezado_margin_top: 150
    encabezado_margin_left: 200
  }
  
  for img in $scope.imagenes
    if img.nombre.includes('fondo-observador.png')
      $scope.observ.imagen = img


  
  $scope.USER = Perfil.User()

  $scope.perfilPath = App.images+'perfil/'


  $scope.$emit 'cambia_descripcion', 'Observador del alumno '
])
