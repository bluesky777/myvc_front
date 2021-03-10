'use strict'

angular.module("myvcFrontApp")

.controller('ParticipantesCtrl', ['$scope', '$filter', '$http', 'toastr', 'Acentos', ($scope, $filter, $http, toastr, Acentos)->

    $scope.participantes	= []
    $scope.dato	= {grupo: ''}
    $scope.gridOptions 		= {}


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
            
            for parti in r.data.participantes
                for aspir in parti.aspiraciones
                    for voto in aspir.votos
                        voto.created_at = new Date(voto.created_at.replace(/-/g, '\/'))
        
            $scope.participantes = r.data.participantes
            $scope.gridOptions.data = r.data.participantes
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


    btUsuario       = "==directives/botonesResetPassword.tpl.html"
    btEditUsername  = "==alumnos/botonEditUsername.tpl.html"
    btEditEPS       = "==alumnos/botonEditEps.tpl.html"
    btVotos         = "==alumnos/botonVotos.tpl.html"
    appendPopover1 = "'==alumnos/popoverAlumnoGrid.tpl.html'"
    appendPopover2 = "'mouseenter'"
    append3 = "' '"
    appendPopover = 'uib-popover-template="views+' + appendPopover1 + '" popover-trigger="'+appendPopover2+'" popover-title="{{ row.entity.nombres + ' + append3 + ' + row.entity.apellidos }}" popover-popup-delay="500" popover-append-to-body="true"'



    $scope.gridOptions =
        showGridFooter: true,
        showColumnFooter: true,
        showFooter: true,
        enableSorting: true,
        enableFiltering: true,
        enebleGridColumnMenu: false,
        columnDefs: [
            { field: 'no', pinnedLeft:true, cellTemplate: '<div class="ui-grid-cell-contents">{{grid.renderContainers.body.visibleRowCache.indexOf(row) + 1}}</div>', width: 40, enableCellEdit: false }
            { field: 'nombres', minWidth: 130, pinnedLeft:true,
            filter: {
                condition: Acentos.buscarEnGrid
            }
            enableHiding: false, cellTemplate: '<div class="ui-grid-cell-contents" style="padding: 0px;" ' + appendPopover + '><img ng-src="{{grid.appScope.perfilPath + row.entity.foto_nombre}}" style="width: 35px" />{{row.entity.nombres}}</div>' }
            { field: 'apellidos', minWidth: 110, filter: { condition: Acentos.buscarEnGrid }}
            { name: 'Votos', cellTemplate: btVotos, minWidth: 200 }
            { field: 'sexo', displayName: 'Sex', width: 40 }
            { field: 'username', filter: { condition: Acentos.buscarEnGrid }, displayName: 'Usuario', cellTemplate: btUsuario, editableCellTemplate: btEditUsername, minWidth: 135 }
            { field: 'documento', minWidth: 100, cellFilter: 'formatNumberDocumento' }
            { field: 'celular', displayName: 'Celular', minWidth: 80 }
        ],
        multiSelect: false,


    return
])
