<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los datos principales de las competencias
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: CompetenciasModel.php 298 2014-06-30 23:59:00Z aranape $
 * @history ''
 *
 * $Date: 2014-06-30 18:59:00 -0500 (lun, 30 jun 2014) $
 * $Rev: 298 $
 */
class CompetenciasModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $competencias_codigo;
    protected $competencias_descripcion;
    protected $competencia_tipo_codigo;
    protected $categorias_codigo;
    protected $paises_codigo;
    protected $ciudades_codigo;
    protected $competencias_fecha_inicio;
    protected $competencias_fecha_final;
    protected $competencias_es_oficial;
    protected $competencias_clasificacion;

    /**
     * I = Indoor
     * O = Outdoor
     *
     * @var char
     */
    private static $_COMPETENCIAS_CLASIFICACION = array('I', 'O');

    public function get_competencias_codigo() {
        return $this->competencias_codigo;
    }

    public function set_competencias_codigo($competencias_codigo) {
        $this->competencias_codigo = $competencias_codigo;
        $this->setId($competencias_codigo);
    }

    public function get_competencias_descripcion() {
        return $this->competencias_descripcion;
    }

    public function set_competencias_descripcion($competencias_descripcion) {
        $this->competencias_descripcion = $competencias_descripcion;
    }

    /**
     * Setea el codigo unico de los tipos de la competencia
     *
     * @param string $competencia_tipo_codigo codigo  unico del pais
     */
    public function set_competencia_tipo_codigo($competencia_tipo_codigo) {
        $this->competencia_tipo_codigo = $competencia_tipo_codigo;
    }

    /**
     * @return string retorna el codigo unico de los tipos de la competencia
     */
    public function get_competencia_tipo_codigo() {
        return $this->competencia_tipo_codigo;
    }

    /**
     * Define la categoria de la competencia , digase  menores ,
     * mayores , juveniles, etc
     *
     * @param string $categorias_codigo
     */
    public function set_categorias_codigo($categorias_codigo) {
        $this->categorias_codigo = $categorias_codigo;
    }

    /**
     * Retorna la categoria de la competencia , digase  menores ,
     * mayores , juveniles, etc
     *
     * @return string
     */
    public function get_categorias_codigo() {
        return $this->categorias_codigo;
    }

    public function get_paises_codigo() {
        return $this->paises_codigo;
    }

    public function set_paises_codigo($paises_codigo) {
        $this->paises_codigo = $paises_codigo;
    }

    public function get_ciudades_codigo() {
        return $this->ciudades_codigo;
    }

    public function set_ciudades_codigo($ciudades_codigo) {
        $this->ciudades_codigo = $ciudades_codigo;
    }

    public function get_competencias_fecha_inicio() {
        return $this->competencias_fecha_inicio;
    }

    public function set_competencias_fecha_inicio($competencias_fecha_inicio) {
        $this->competencias_fecha_inicio = $competencias_fecha_inicio;
    }

    public function get_competencias_fecha_final() {
        return $this->competencias_fecha_final;
    }

    public function set_competencias_fecha_final($competencias_fecha_final) {
        $this->competencias_fecha_final = $competencias_fecha_final;
    }

    /**
     * Retorna si la competencia se registrara como oficial o no.
     * @return boolean
     */
    public function get_competencias_es_oficial() {
        return $this->competencias_es_oficial;
    }

    /**
     * Setea si la competencia se registrara como oficial o no.
     * @param boolean $competencias_es_oficial
     */
    public function set_competencias_es_oficial($competencias_es_oficial) {
        $this->competencias_es_oficial = $competencias_es_oficial;
    }

    /**
     * Setea la clasificacion de la competencia :
     *
     *  I = Indoor.
     *  O = Outdoor.
     *
     * @param char $competencias_clasificacion indicando la clasificacion de la competencia
     * los valores pueden ser 'I','O'
     */
    public function set_competencias_clasificacion($competencias_clasificacion) {
        $competencias_clasificacion_u = strtoupper($competencias_clasificacion);

        if (in_array($competencias_clasificacion_u, CompetenciasModel::$_COMPETENCIAS_CLASIFICACION)) {
            $this->competencias_clasificacion = $competencias_clasificacion_u;
        } else {
            $this->competencias_clasificacion = '?'; // Causara error en base de datos
        }
    }

    /**
     * Retorna la clasificacion de la competencia
     *
     * @return char indicando la clasificacion de la competencia
     * los valores pueden ser 'I','O'
     */
    public function get_competencias_clasificacion() {
        return $this->competencias_clasificacion;
    }

    public function &getPKAsArray() {
        $pk['competencias_codigo'] = $this->getId();
        return $pk;
    }

}

?>