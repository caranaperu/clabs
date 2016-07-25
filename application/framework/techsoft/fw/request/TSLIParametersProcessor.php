<?php

/**
 * Define los metodos a implementar para un procesador de parametros
 * en general (normalmente http parameters).
 *
 * @author		Carlos Arana Reategui.
 * @license		GPL
 * @since		Version 1.0
 */
interface TSLIParametersProcessor {

    /**
     * Funcion a implementar para procesar los datos del filtro
     * de acuerdo a los diversos formatos.
     *
     * @param filterData mixed objeto , string, etc que representa
     * los datos del filtro.
     * @param Object reference donde se colocara la data procesada, puede ser null
     * en cuyo caso podra devolverse un arreglo con los valores u otro tipo de objeto
     * segun la necesidad.
     *
     * @return Object con los resultados
     */
    public function &process($filterData,  &$processedObject = NULL);
}

?>
