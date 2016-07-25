<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para definir las pruebas que corresponden a una competencia.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: CompetenciasPruebasModelTraits.php 195 2014-06-23 19:54:42Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 14:54:42 -0500 (lun, 23 jun 2014) $
 * $Rev: 195 $
 */
trait CompetenciasPruebasModelTraits  {
    protected $competencias_pruebas_id;
    protected $competencias_codigo;
    protected $pruebas_codigo;
    protected $competencias_pruebas_fecha;
    protected $competencias_pruebas_viento;
    protected $competencias_pruebas_manual;
    protected $competencias_pruebas_tipo_serie;
    protected $competencias_pruebas_nro_serie;
    protected $competencias_pruebas_anemometro;
    protected $competencias_pruebas_material_reglamentario;
    protected $competencias_pruebas_origen_combinada;
    protected $competencias_pruebas_observaciones;

    // Si es hit,serie,semifinal,final
    public static $_TIPO_SERIE = array('HT', 'SR', 'SM', 'FI', 'SU');

    /**
     * Setea el id unico de la relacion competencias-pruebas
     *
     * @param integer $competencias_pruebas_id unico de la relacion competencias-pruebas
     */
    public function set_competencias_pruebas_id($competencias_pruebas_id) {
        $this->competencias_pruebas_id = $competencias_pruebas_id;
        $this->setId($competencias_pruebas_id);
    }

    /**
     * @return integer retorna el id unico de la relacion competencias-pruebas
     */
    public function get_competencias_pruebas_id() {
        return $this->competencias_pruebas_id;
    }

    /**
     * Setea el codigo de la competencia
     *
     * @param string $competencias_codigo  de la competencia
     */
    public function set_competencias_codigo($competencias_codigo) {
        $this->competencias_codigo = $competencias_codigo;
    }

    /**
     *
     * @return string con el codigo  de la competencia
     */
    public function get_competencias_codigo() {
        return $this->competencias_codigo;
    }

    /**
     *
     * @return string que representa el codigo de la prueba
     * atletica.
     */
    public function get_pruebas_codigo() {
        return $this->pruebas_codigo;
    }

    /**
     * Setea el codigo de la prueba atletica
     *
     * @param string $pruebas_codigo codigo de la prueba atletica
     */
    public function set_pruebas_codigo($pruebas_codigo) {
        $this->pruebas_codigo = $pruebas_codigo;
    }

    /**
     *
     * @return string retorna la fecha de la prueba
     */
    public function get_competencias_pruebas_fecha() {
        return $this->competencias_pruebas_fecha;
    }

    /**
     * Setea la fecha de la prueba
     * @param string $competencias_pruebas_fecha
     */
    public function set_competencias_pruebas_fecha($competencias_pruebas_fecha) {
        $this->competencias_pruebas_fecha = $competencias_pruebas_fecha;
    }

    /**
     * Indica el viento con que se realizo la prueba , esto es solo
     * valido para las pruebas de velocidad o salto largo.
     *
     * @return float con el viento con que se  realizo la prueba.
     */
    public function get_competencias_pruebas_viento() {
        if (!isset($this->competencias_pruebas_viento)) {
            return null;
        }
        return $this->competencias_pruebas_viento;
    }

    /**
     * Setea el viento con que se realizo la prueba, es es solo valido para
     * las pruebas de velocidad o  salto largo.
     *
     * @param float $competencias_pruebas_viento
     */
    public function set_competencias_pruebas_viento($competencias_pruebas_viento) {
        $this->competencias_pruebas_viento = $competencias_pruebas_viento;
    }

    /**
     * Indica si un resultado tuvo o no anemometro. Es valido para las pruebas
     * de velocidad y saltos horizontales
     *
     * @return boolean true si hubo anemometro false si no.
     */
    public function get_competencias_pruebas_anemometro() {
        if (!isset($this->competencias_pruebas_anemometro)) {
            return 'false';
        }
        return $this->competencias_pruebas_anemometro;
    }

    /**
     * Setea si resultado tuvo o no anemometro. Es valido para las pruebas
     * de velocidad y saltos horizontales
     *
     * @param boolean $competencias_pruebas_anemometro true ssi hubo anemometro false si no.
     */
    public function set_competencias_pruebas_anemometro($competencias_pruebas_anemometro) {
        if ($competencias_pruebas_anemometro !== 'true' && $competencias_pruebas_anemometro !== 'TRUE' &&
                $competencias_pruebas_anemometro !== TRUE && $competencias_pruebas_anemometro != 't' &&
                $competencias_pruebas_anemometro != 'T' && $competencias_pruebas_anemometro != '1') {
            $this->competencias_pruebas_anemometro = 'false';
        } else {
            $this->competencias_pruebas_anemometro = 'true';
        }
    }

    /**
     *
     * @return boolean true si la prueba fue con tiempo manual, false de lo contrario.
     */
    public function get_competencias_pruebas_manual() {
        if (!isset($this->competencias_pruebas_manual)) {
            return 'false';
        }
        return $this->competencias_pruebas_manual;
    }

    /**
     * Se indica si la prueba fue con tiempo manual.
     *
     * @param boolean $competencias_pruebas_manual true si la prueba fue con tiempo manual,
     * false de lo contrario.
     */
    public function set_competencias_pruebas_manual($competencias_pruebas_manual) {
        if ($competencias_pruebas_manual !== 'true' && $competencias_pruebas_manual !== 'TRUE' &&
                $competencias_pruebas_manual !== TRUE && $competencias_pruebas_manual != 't' &&
                $competencias_pruebas_manual != 'T' && $competencias_pruebas_manual != '1') {
            $this->competencias_pruebas_manual = 'false';
        } else {
            $this->competencias_pruebas_manual = 'true';
        }
    }

    /**
     *
     * @return boolean true si la prueba es parte de una combinada
     */
    public function get_competencias_pruebas_origen_combinada() {
        return $this->competencias_pruebas_origen_combinada;
    }

    /**
     * Setea si la prueba es parte de una combinada.
     *
     * @param boolean $competencias_pruebas_origen_combinada true si es parte de una combinada.
     */
    public function set_competencias_pruebas_origen_combinada($competencias_pruebas_origen_combinada) {
        $this->competencias_pruebas_origen_combinada = $competencias_pruebas_origen_combinada;
    }


    /**
     *
     * @return boolean true si hubo problema con el material de la prueba., false de lo contrario
     */
    public function get_competencias_pruebas_material_reglamentario() {
        if (!isset($this->competencias_pruebas_material_reglamentario)) {
            return 'false';
        }
        return $this->competencias_pruebas_material_reglamentario;
    }

    /**
     * Setea si hubo problema con el material de la prueba
     *
     * @param boolean $competencias_pruebas_material_reglamentario ture si el material tuvo problemas,
     * flase de lo contrario.
     */
    public function set_competencias_pruebas_material_reglamentario($competencias_pruebas_material_reglamentario) {
        $this->competencias_pruebas_material_reglamentario = $competencias_pruebas_material_reglamentario;

        if ($competencias_pruebas_material_reglamentario !== 'true' && $competencias_pruebas_material_reglamentario !== 'TRUE' &&
                $competencias_pruebas_material_reglamentario !== TRUE && $competencias_pruebas_material_reglamentario != 't' &&
                $competencias_pruebas_material_reglamentario != 'T' && $competencias_pruebas_material_reglamentario != '1') {
            $this->competencias_pruebas_material_reglamentario = 'false';
        } else {
            $this->competencias_pruebas_material_reglamentario = 'true';
        }
    }

    /**
     * Retorna el tipo de serie de la prueba
     * @return string HT - Hit , SR - Serie , SM - Semifinal , FI - final , NN - no indicado
     */
    public function get_competencias_pruebas_tipo_serie() {
        return $this->competencias_pruebas_tipo_serie;
    }

    /**
     * Indica el tipo de serie de la prueba.
     *
     * sera
     *  HT - Hit ,
     *  SR - Serie ,
     *  SM - Semifinal ,
     *  FI - final ,
     * SU - no indicado
     *
     * @param char $competencias_pruebas_tipo_serie
     */
    public function set_competencias_pruebas_tipo_serie($competencias_pruebas_tipo_serie) {
        $competencias_pruebas_tipo_serie_u = strtoupper($competencias_pruebas_tipo_serie);

        if (in_array($competencias_pruebas_tipo_serie_u, CompetenciasPruebasModelTraits::$_TIPO_SERIE)) {
            $this->competencias_pruebas_tipo_serie = $competencias_pruebas_tipo_serie_u;
        } else {
            $this->competencias_pruebas_tipo_serie = 'SU';
        }
    }

    /**
     *
     * @return int con el numero de la serie
     */
    public function get_competencias_pruebas_nro_serie() {
        return $this->competencias_pruebas_nro_serie;
    }

    /**
     *
     * @param int $competencias_pruebas_nro_serie con el numero de la serie.
     */
    public function set_competencias_pruebas_nro_serie($competencias_pruebas_nro_serie) {
        $this->competencias_pruebas_nro_serie = $competencias_pruebas_nro_serie;
    }


    public function get_competencias_pruebas_observaciones() {
        return $this->competencias_pruebas_observaciones;
    }

    public function set_competencias_pruebas_observaciones($competencias_pruebas_observaciones) {
        $this->competencias_pruebas_observaciones = $competencias_pruebas_observaciones;
    }

}

?>