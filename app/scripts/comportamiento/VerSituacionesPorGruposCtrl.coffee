angular.module('myvcFrontApp')

.controller('VerSituacionesPorGruposCtrl', ['$scope', 'toastr', 'grupos_situaciones', ($scope, toastr, grupos_situaciones)->
  $scope.grupos_situaciones   = grupos_situaciones.data.grupos;
  $scope.year                 = $scope.$parent.year;
  console.log($scope.$parent.year);
])
