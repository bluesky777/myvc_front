angular.module('myvcFrontApp')

.factory('GruposServ', ['RGrupos', '$q', (RGrupos, $q) ->
	
	grupos = []

	interfaz = {
		getGrupos: ()->
			d = $q.defer()

			console.log 'grupos.length', grupos.length
			if grupos.length > 0
				d.resolve(grupos)
			else
				RGrupos.getList().then((r)->
					grupos = r
					d.resolve(grupos)
				, (r2)->
					d.reject(r2)
				)

			return d.promise

			
	}
	return interfaz;
])
