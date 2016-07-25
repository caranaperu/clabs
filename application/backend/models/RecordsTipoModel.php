<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los tipos de records atleticos , tales como
 * mundial,olimpico, etc.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: RecordsTipoModel.php 361 2016-01-24 22:29:58Z aranape $
 * @history ''
 *
 * $Date: 2016-01-24 17:29:58 -0500 (dom, 24 ene 2016) $
 * $Rev: 361 $
 */
class RecordsTipoModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $records_tipo_codigo;
    protected $records_tipo_descripcion;
    protected $records_tipo_abreviatura;
    protected $records_tipo_tipo;
    protected $records_tipo_clasificacion;
    protected $records_tipo_peso;
    protected $records_tipo_protected;

    /**
     * A = Absoluto
     * C = Campeonato
     *
     * @var char
     */
    private static $_RECORDS_TIPO = array('A', 'C');

    /**
     * O = Olimpico
     * M = Mundial
     * R = Regional
     * X = Otros
     * N = Nacional
     * T = Regional Superior , por ejemplo Panamericano
     *
     * @var char
     */
    private static $_RECORDS_CLASIFICACION = array('O', 'M', 'R', 'X','N','T');

    /**
     * Setea el codigo unico del pais.
     *
     * @param string $records_tipo_codigo codigo  unico del pais
     */
    public function set_records_tipo_codigo($records_tipo_codigo) {
        $this->records_tipo_codigo = $records_tipo_codigo;
        $this->setId($records_tipo_codigo);
    }

    /**
     * @return string retorna el codigo unico del pais.
     */
    public function get_records_tipo_codigo() {
        return $this->records_tipo_codigo;
    }

    /**
     * Setea el nombre del pais.
     *
     * @param string $records_tipo_descripcion nombre del pais
     */
    public function set_records_tipo_descripcion($records_tipo_descripcion) {
        $this->records_tipo_descripcion = $records_tipo_descripcion;
    }

    /**
     *
     * @return string con el nombre del pais
     */
    public function get_records_tipo_descripcion() {
        return $this->records_tipo_descripcion;
    }

    /**
     * Retorna la abreviatura asignada a este tipo de record
     *
     * @return string la abreviatura asignada a este tipo de record
     */
    public function get_records_tipo_abreviatura() {
        return $this->records_tipo_abreviatura;
    }

    /**
     * Setea Retorna la abreviatura asignada a este tipo de record
     *
     * @param string $records_tipo_abreviatura la abreviatura asignada a este tipo de record
     */
    public function set_records_tipo_abreviatura($records_tipo_abreviatura) {
        $this->records_tipo_abreviatura = $records_tipo_abreviatura;
    }

    /**
     * El peso asignado al tipo de record.
     *
     * @return int con el peso a asignar al tipo de record
     */
    public function get_records_tipo_peso() {
        return $this->records_tipo_peso;
    }

    /**
     * Setea el peso asignado al tipo de record , mas peso
     * mas valor absoluto , digamos el RM 500 , el Record SudAmericano 100.
     * Para records de competencias locales se usa menos de 100.
     *
     * @param int $records_tipo_peso
     */
    public function set_records_tipo_peso($records_tipo_peso) {
        $this->records_tipo_peso = $records_tipo_peso;
    }

    /**
     * Setea el tipo de record indicando :
     *  A = Absoluto.
     *  C = Competencia.
     *
     * @param char $records_tipo_tipo indicando el tipo de record.
     * los valores pueden ser 'A','C'
     */
    public function set_records_tipo_tipo($records_tipo_tipo) {
        $records_tipo_tipo_u = strtoupper($records_tipo_tipo);

        if (in_array($records_tipo_tipo_u, RecordsTipoModel::$_RECORDS_TIPO)) {
            $this->records_tipo_tipo = $records_tipo_tipo_u;
        } else {
            $this->records_tipo_tipo = '?'; // Causara error en base de datos
        }
    }

    /**
     * Retorna el tipo de record.
     *
     * @return char indicando el tipo de record.
     * los valores pueden ser 'A','C'
     */
    public function get_records_tipo_tipo() {
        return $this->records_tipo_tipo;
    }

    /**
     * Setea la clasificacion del record :
     *
     * O = Olimpico
     * M = Mundial
     * R = Regional
     * X = Otros
     * N = Nacional
     * T = Regional Superior , por ejemplo Panamericano
     *
     * @param char $records_tipo_clasificacion indicando la clasificacion del record
     * los valores pueden ser 'O', 'M', 'R', 'X','N','T'
     */
    public function set_records_tipo_clasificacion($records_tipo_clasificacion) {
        $records_tipo_clasificacion_u = strtoupper($records_tipo_clasificacion);

        if (in_array($records_tipo_clasificacion_u, RecordsTipoModel::$_RECORDS_CLASIFICACION)) {
            $this->records_tipo_clasificacion = $records_tipo_clasificacion_u;
        } else {
            $this->records_tipo_clasificacion = '?'; // Causara error en base de datos
        }
    }

    /**
     * Retorna la clasificacion del record
     *
     * @return char indicando el tipo de record.
     * los valores pueden ser 'O', 'M', 'R', 'X','N','T'
     */
    public function get_records_tipo_clasificacion() {
        return $this->records_tipo_clasificacion;
    }

    /**
     *
     * @return boolean true si el registro no puede modificarse o eliminarse
     */
    public function get_records_tipo_protected() {
        return $this->records_tipo_protected;
    }

    /**
     * Se indica si un registro estara o no protegido de cualquier operacion
     * CRUD.
     *
     * @param boolean $records_tipo_protected  true si el registro esta protegido.
     */
    public function set_records_tipo_protected($records_tipo_protected) {
        if ($records_tipo_protected !== 'true' && $records_tipo_protected !== 'TRUE' &&
                $records_tipo_protected !== TRUE && $records_tipo_protected != 't' &&
                $records_tipo_protected != 'T' && $records_tipo_protected != '1') {
            $this->records_tipo_protected = 'false';
        } else {
            $this->records_tipo_protected = 'true';
        }
    }

    public function &getPKAsArray() {
        $pk['records_tipo_codigo'] = $this->getId();
        return $pk;
    }

}

?>