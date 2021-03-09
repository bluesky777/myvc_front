'use strict'

angular.module("myvcFrontApp")

.controller('ParticipantesCtrl', ['$scope', '$filter', '$http', 'toastr', ($scope, $filter, $http, toastr)->

    $scope.participantes	= []
    $scope.dato	= {grupo: ''}


    $scope.votacion = {
        locked: false
        is_action: false
        fecha_inicio: ''
        fecha_fin: ''
    }


    $http.put('::participantes/datos').then((data)->
        data = data.data
        $scope.grupos 			= data.grupos;
        $scope.votacion 		= data.votacion;
        matr_grupo = 0

        if localStorage.matr_grupo
            matr_grupo = parseInt(localStorage.matr_grupo)

        for grupo in $scope.grupos
            if parseInt(grupo.id) == parseInt(matr_grupo)
                $scope.dato.grupo = grupo
                $scope.selectGrupo($scope.dato.grupo)


    , (r2)->
        toastr.warning 'Asegúrate de tener al menos un evento como actual.'
    )


    $scope.selectGrupo = (grupo)->
        localStorage.matr_grupo = grupo.id
        $scope.dato.grupo 		= grupo

        for grup in $scope.grupos
            grup.active = false

        grupo.active = true
    
        $http.put('::participantes/votantes', {grupo_id: grupo.id, votacion_id: $scope.votacion.id}).then((r)->
            $scope.participantes = r.data.participantes
        , (r2)->
            toastr.error 'Error al traer participantes.'
        )



    $scope.guardarInscripciones = ()->
        $scope.guardando_inscrip = true
        $http.put('::participantes/guardar-inscripciones', {grupos: $scope.grupos}).then((r)->
            toastr.success 'Inscripciones guardadas.'
            $scope.guardando_inscrip = false
        , (r2)->
            toastr.error 'Error al intentar guardar Inscripciones.'
            $scope.guardando_inscrip = false
        )

    return
])
