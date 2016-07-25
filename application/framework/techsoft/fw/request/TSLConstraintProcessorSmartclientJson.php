<?php

/**
 * Procesador default para constraint de query basado en JSON y especificamente para
 * la libreria smartclient.
 *
 * @author		Carlos Arana Reategui.
 * @license		GPL
 * @since		Version 1.0
 */
class TSLConstraintProcessorSmartclientJson implements TSLIParametersProcessor {

    /**
     * Parseara los parametros para formar los constraints basados en los
     * datos del request.
     *
     * En el caso de SmarClient esos son basicamente :
     * _startRow = primera fila a enviar del total de los resultados.
     * _endRow = Ultima fila a enviar del total de los resultados.
     * @todo  Agregar el resto conforme se vayan implementando.
     *
     *
     * @param Object $constraintData para el caso de este processor basado en
     * JSON , el string que contiene el objeto Json con los valores requeridos.
     * @param \TSLRequestConstraints $constraints referencia a un objeto constraints
     * si a existe uno creado.
     *
     * @return \TSLRequestConstraints la estructura de los constraints a procesar.
     */
    public function &process($constraintData, &$constraints = NULL) {
        $startRow = 0;
        $endRow = 0;


        // Si el parametro no es valido retornamos un arreglo en blanco
        if (!isset($constraintData) || is_null($constraintData)) {
            return NULL;
        }


        if (isset($constraintData['_startRow'])) {
            $startRow = $constraintData['_startRow'];
        }

        if (isset($constraintData['_endRow'])) {
            $endRow = $constraintData['_endRow'];
        }

        // Creamos si no se envia uno para usar.
        if (!isset($constraints) || $constraints === NULL) {
            $constraints = new TSLRequestConstraints();
        }

        // Campos de sort (primer intento un solo campo).
        // El sort viene con un negativo adelante si es descendente
        if (isset($constraintData['_sortBy'])) {
            $pos = strpos($constraintData['_sortBy'], '-');
            if ($pos !== FALSE) {
                $constraints->addSortField(substr($constraintData['_sortBy'], 1), 'DESC');
            } else {
                $constraints->addSortField($constraintData['_sortBy'], 'ASC');
            }
        }

        // Seteamos los datos
        $constraints->setStartRow($startRow);
        $constraints->setEndRow($endRow);

        // Vemos si tenemos que procesar un advanced filter
        // De lo contrario solo efectuamos un filtro normal.
        if (isset($constraintData['_acriteria'])) {
            $afilter = json_decode($constraintData['_acriteria']);

            foreach ($afilter->criteria as $elem) {
                $constraints->addFilterField($elem->fieldName, $elem->value, $elem->operator);
            }
        } else {

            // Los campos de filtro , para el smartClient son todos aquellos que
            // no tienen el underscore delante.
            foreach ($constraintData as $key => $value) {
                // Si empieza con op o libid o parentId son parametros para otors usos no
                // son campos.
                if (!strcmp($key, "op") || !strcmp($key, "libid") || !strcmp($key, "parentId")) {
                    continue;
                }

                // Si no empieza con underscore o _isc (isomorphic smartclient identificador)
                $pos = strpos($key, '_');
                $pos2 = strpos($key, 'isc_');
                if (!($pos === 0 || $pos2 === 0)) {
                    if (isset($constraintData['_textMatchStyle'])) {
                        $constraints->addFilterField($key, $value, $constraintData['_textMatchStyle']);
                    } else {
                        $constraints->addFilterField($key, $value, $constraintData[$key]);
                    }
                }
            }
        }
        return $constraints;
    }

}

?>
