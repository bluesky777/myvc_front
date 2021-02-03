angular.module('myvcFrontApp')


# Configuración principal de nuestra aplicación.
.config(['$stateProvider', 'App', 'PERMISSIONS', ($state, App, PERMISSIONS)->


  $state

    .state 'panel.disciplina',
      url: '^/disciplina'
      views:
        'maincontent':
          templateUrl: "==comportamiento/disciplina.tpl.html"
          controller: 'DisciplinaCtrl'
          resolve:
            escalas: ['EscalasValorativasServ', (EscalasValorativasServ)->
              EscalasValorativasServ.escalas()
            ]
        'headerContent':
          templateUrl: "==panel/panelHeader.tpl.html"
          controller: 'PanelHeaderCtrl'
          resolve:
            titulo: [->
              'Disciplina'
            ]
      data:
        displayName: 'Disciplina'
        icon_fa: 'fa fa-user'
        needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin]
        pageTitle: 'Disciplina - MyVc'



    .state 'panel.disciplina.ver-situaciones-por-grupos',
      url: '/ver-situaciones-por-grupos'
      views:
        'report_content':
          templateUrl: "==comportamiento/verSituacionesPorGrupos.tpl.html"
          controller: 'VerSituacionesPorGruposCtrl' # En VerSituacionesPorGruposCtrl.coffee
          resolve:
            grupos_situaciones: ['$http', '$stateParams', ($http, $stateParams)->
              $http.put('::comportamiento/situaciones-por-grupos')
            ]
      data:
        displayName: 'Situaciones por grupos'
        icon_fa: 'fa fa-print'
        pageTitle: 'Situaciones por grupos - MyVc'



    .state 'panel.ordinales',
      url: '^/ordinales'
      views:
        'maincontent':
          templateUrl: "==comportamiento/ordinales.tpl.html"
          controller: 'OrdinalesCtrl'
        'headerContent':
          templateUrl: "==panel/panelHeader.tpl.html"
          controller: 'PanelHeaderCtrl'
          resolve:
            titulo: [->
              'Ordinales'
            ]
      data:
        displayName: 'Ordinales'
        icon_fa: 'fa fa-user'
        needed_permissions: [PERMISSIONS.can_work_like_teacher, PERMISSIONS.can_work_like_admin]
        pageTitle: 'Ordinales - MyVc'





  return
])

