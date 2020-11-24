angular.module('myvcFrontApp')

.directive('updateTitle', ['$rootScope', '$timeout',
    ($rootScope, $timeout)->
            link: (scope, element)->

                ###

                $transitions.onSuccess({}, (transition)->

                    title = 'Wissen'
                    if transition.to().data and transition.to().data.pageTitle
                        title = transition.to().data.pageTitle

                    if transition.to().Params
                        if transition.to().Params.username
                            title = transition.to().Params.username + ' - Wissen'

                    $timeout(()->
                        element.text(title)
                    , 0, false)
                );

                ###

                listener = (event, toState, toParams)->

                    title = 'MyVc'
                    if toState.data and toState.data.pageTitle
                        title = toState.data.pageTitle

                    if toParams
                        if toParams.username
                            title = toParams.username + ' - MyVC'
                    
                    if toState.data.pageTitle == 'Boletines periodo - MyVc' or toState.data.pageTitle == 'Boletines finales - MyVc'
                        if localStorage.grupo_boletines
                            title = localStorage.grupo_boletines + ' - MyVC'
                        else if localStorage.alumno_boletin
                            title = localStorage.alumno_boletin


                    $timeout(()->
                        element.text(title)
                    , 0, false)

                $rootScope.$on('$stateChangeSuccess', listener)
])
