<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Interfase base para controladores que manejen requerimientos de
 * data con order by , limites de numero de registros u filtros.
 *
 * @author carana
 */
interface TSLIConstrainedController  {


    /**
     * Metodo hook que se usara si se desea utilizar por default
     * un procesador de filtro diferente al default.
     * Si se desea uno diferente hacer override , de lo contrario retorna
     * null , que es lo mismo que indicar usese el default.
     *
     * @return string null el default del sistema , != null nombre base de la clase
     * que se usara como filtro default.
     *
     * @see TSLFilterProcessorLoaderHelper
     * @see TSLFilterProcessorJson
     */
    public function getFilterProcessor();

    /**
     * Metodo hook que se usara si se desea utilizar por default
     * un procesador de campos de sort diferente al default.
     * Si se desea uno diferente hacer override , de lo contrario retorna
     * null , que es lo mismo que indicar usese el default.
     *
     * @return string null el default del sistema , != null nombre base de la clase
     * que se usara como sorter default.
     *
     * @see TSLSorterProcessorLoaderHelper
     * @see TSLSorterProcessorJson
     */
    public function getSorterProcessor() ;

    /**
     * Metodo hook que se usara si se desea utilizar por default
     * un procesador de constraint diferente al default.
     * Si se desea uno diferente hacer override , de lo contrario retorna
     * null , que es lo mismo que indicar usese el default.
     *
     * @return string null el default del sistema , != null nombre base de la clase
     * que se usara como constraint processor default.
     *
     * @see \TSLConstraintProcessorLoaderHelper
     */
    public function getConstraintProcessor();

    /**
     * Define el tipo de parser default para el filtro el cual
     * puede ser json,csv o xml.
     *
     * @return string con el tipo de datos que componen el filtro json,csv o xml
     */
    public function getDefaultFilterType() ;

    /**
     * Define el tipo de parser default para los campos de sort el cual
     * puede ser json,csv o xml.
     *
     * @return string con el tipo de datos que componen el sorter json,csv o xml
     */
    public function getDefaultSorterType();


}
?>


