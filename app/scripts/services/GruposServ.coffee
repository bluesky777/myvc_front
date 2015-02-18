angular.module('myvcFrontApp')

.factory('GruposServ', ['RGrupos', (RGrupos) ->
	
	interfaz = {
		getGrupos: ()->
			RGrupos.getList()
	}
	return interfaz;
])
