<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las ciudades donde se realizan las
 * competencias, deben estar asociados a un pais.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: CiudadesModel.php 196 2014-06-23 19:57:09Z aranape $
 * @history ''
 *
 * $Date: 2014-06-23 14:57:09 -0500 (lun, 23 jun 2014) $
 * $Rev: 196 $
 */
class CiudadesModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $ciudades_codigo;
    protected $ciudades_descripcion;
    protected $paises_codigo;
    protected $ciudades_altura;

    /**
     * Setea el codigo unico de la ciudad.
     *
     * @param string $ciudades_codigo codigo  unico de la ciudad
     */
    public function set_ciudades_codigo($ciudades_codigo) {
        $this->ciudades_codigo = $ciudades_codigo;
        $this->setId($ciudades_codigo);
    }

    /**
     * @return string retorna el codigo unico del pais.
     */
    public function get_ciudades_codigo() {
        return $this->ciudades_codigo;
    }

    /**
     * Setea el nombre de la ciudad
     *
     * @param string $ciudades_descripcion nombre de la ciudad
     */
    public function set_ciudades_descripcion($ciudades_descripcion) {
        $this->ciudades_descripcion = $ciudades_descripcion;
    }

    /**
     *
     * @return string con el nombre de la ciudad
     */
    public function get_ciudades_descripcion() {
        return $this->ciudades_descripcion;
    }

    /**
     * Indica a que pais pertenece la ciudad
     *
     * @return string con el codigo del pais
     */
    public function get_paises_codigo() {
        return $this->paises_codigo;
    }

    /**
     * Setea el codigo del pais al que pertenece la ciudad
     *
     * @param string $paises_codigo  pais al que pertenece la ciudad
     */
    public function set_paises_codigo($paises_codigo) {
        $this->paises_codigo = $paises_codigo;
    }

    /**
     * Retorna si la ciudad se considera para el atletismo una ciudad de altura.
     *
     * @return boolean true si la ciudad esta en altura.
     */
    public function get_ciudades_altura() {
        if (!isset($this->ciudades_altura)) {
            return 'false';
        }
        return $this->ciudades_altura;
    }

    /**
     * Setea si la ciudad se considera para el atletismo una ciudad de altura.
     *
     * @param boolean $ciudades_altura true si esta en altura.
     */
    public function set_ciudades_altura($ciudades_altura) {
        if ($ciudades_altura !== 'true' && $ciudades_altura !== 'TRUE' &&
                $ciudades_altura !== TRUE && $ciudades_altura != 't' &&
                $ciudades_altura != 'T' && $ciudades_altura != '1') {
            $this->ciudades_altura = 'false';
        } else {
            $this->ciudades_altura = 'true';
        }
    }

    public function &getPKAsArray() {
        $pk['ciudades_codigo'] = $this->getId();
        return $pk;
    }

}

?>