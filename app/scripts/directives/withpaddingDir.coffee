angular.module('myvcFrontApp')

.directive('withpaddingDir', ['$rootScope', '$state',
	($rootScope, $state)->
			link: (scope, element)->

				listener = (event, toState, toParams)->

					if $state.includes('panel.actividades') or $state.includes('panel.mis_actividades')
						$(element).addClass('no-padding')
					else
						$(element).removeClass('no-padding')



				listener2 = (event, viewConfig)->

					if $state.includes('panel.actividades') or $state.includes('panel.mis_actividades')
						$(element).addClass('no-padding')
					else
						$(element).removeClass('no-padding')



				$rootScope.$on('$stateChangeSuccess', listener)
				$rootScope.$on('$viewContentLoaded', listener2)
])
