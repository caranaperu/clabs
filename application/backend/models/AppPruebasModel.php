<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las genericas de las pruebas atleticas , es una tabla de aplicacion.
 * Aqui se define basicamente si una prueba es multiple , sus valores minimo y maximo validos , si usa limites
 * de viento, etc
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: AppPruebasModel.php 186 2014-06-04 07:50:12Z aranape $
 * @history ''
 *
 * $Date: 2014-06-04 02:50:12 -0500 (mié, 04 jun 2014) $
 * $Rev: 186 $
 */
class AppPruebasModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $apppruebas_codigo;
    protected $apppruebas_descripcion;
    protected $pruebas_clasificacion_codigo;
    protected $apppruebas_marca_menor;
    protected $apppruebas_marca_mayor;
    protected $apppruebas_multiple;
    protected $apppruebas_verifica_viento;
    protected $apppruebas_viento_individual;
    protected $apppruebas_viento_limite_normal;
    protected $apppruebas_viento_limite_multiple;
    protected $apppruebas_nro_atletas;
    protected $apppruebas_factor_manual;

    /**
     * Setea el codigo que representara la generica de una prueba
     *
     * @param string $apppruebas_codigo codigo que representara la generica de una prueba
     */
    public function set_apppruebas_codigo($apppruebas_codigo) {
        $this->apppruebas_codigo = $apppruebas_codigo;
        $this->setId($apppruebas_codigo);
    }

    /**
     * @return string retorna el codigo que representara la generica de una prueba
     */
    public function get_apppruebas_codigo() {
        return $this->apppruebas_codigo;
    }

    /**
     * Setea la descripcion generica de la prueba
     *
     * @param string $apppruebas_descripcion descripcion
     */
    public function set_apppruebas_descripcion($apppruebas_descripcion) {
        $this->apppruebas_descripcion = $apppruebas_descripcion;
    }

    /**
     *
     * @return string la descripcion de la generica de la prueba,
     */
    public function get_apppruebas_descripcion() {
        return $this->apppruebas_descripcion;
    }

    /**
     *
     * @return string retorna el codigo de la clasificacion de la prueba
     */
    public function get_pruebas_clasificacion_codigo() {
        return $this->pruebas_clasificacion_codigo;
    }

    /**
     * Setea el codigo de la clasificacion de la prueba , estas
     * pueden ser de VELOCIDAD,LANZAMIENTO,ETC.
     *
     * @param string $pruebas_clasificacion_codigo
     */
    public function set_pruebas_clasificacion_codigo($pruebas_clasificacion_codigo) {
        $this->pruebas_clasificacion_codigo = $pruebas_clasificacion_codigo;
    }

    /**
     * @return string la menor marca valida
     */
    public function get_apppruebas_marca_menor() {
        return $this->apppruebas_marca_menor;
    }

    /**
     * Setea la menor marca valida. El formato sera string
     * ya que a veces se interpreta has el milisegundo y no es posible indicarlo
     * como numero.
     *
     * @param string $apppruebas_marca_menor
     */
    public function set_apppruebas_marca_menor($apppruebas_marca_menor) {
        $this->apppruebas_marca_menor = $apppruebas_marca_menor;
    }

    /**
     * @return string la mayor marca valida
     */
    public function get_apppruebas_marca_mayor() {
        return $this->apppruebas_marca_mayor;
    }

    /**
     * Setea la mayor marca valida El formato sera string
     * ya que a veces se interpreta has el milisegundo y no es posible indicarlo
     * como numero.

     * @param string $apppruebas_marca_mayor
     */
    public function set_apppruebas_marca_mayor($apppruebas_marca_mayor) {
        $this->apppruebas_marca_mayor = $apppruebas_marca_mayor;
    }

    /**
     *
     * @return boolean true si la prueba es multiple o combinada
     */
    public function get_apppruebas_multiple() {
        return $this->apppruebas_multiple;
    }

    /**
     * Setea si una prueba es multiple o combinada , se
     * indica que lo es coon true de lo contrario false.
     *
     * @param boolean $apppruebas_multiple
     */
    public function set_apppruebas_multiple($apppruebas_multiple) {
        if ($apppruebas_multiple !== 'true' && $apppruebas_multiple !== 'TRUE' &&
                $apppruebas_multiple !== TRUE && $apppruebas_multiple != 't' &&
                $apppruebas_multiple != 'T' && $apppruebas_multiple != '1') {
            $this->apppruebas_multiple = 'false';
        } else {
            $this->apppruebas_multiple = 'true';
        }
    }

    /**
     *
     * @return boolean true si la prueba requiere verificacion de viento
     */
    public function get_apppruebas_verifica_viento() {
        return $this->apppruebas_verifica_viento;
    }

    /**
     * Setea si la prueba requiere verificacion de viento , true
     * si lo es , false de lo contrario.
     *
     * @param boolean $apppruebas_verifica_viento
     */
    public function set_apppruebas_verifica_viento($apppruebas_verifica_viento) {
        if ($apppruebas_verifica_viento !== 'true' && $apppruebas_verifica_viento !== 'TRUE' &&
                $apppruebas_verifica_viento !== TRUE && $apppruebas_verifica_viento != 't' &&
                $apppruebas_verifica_viento != 'T' && $apppruebas_verifica_viento != '1') {
            $this->apppruebas_verifica_viento = 'false';
        } else {
            $this->apppruebas_verifica_viento = 'true';
        }
    }

    /**
     *
     * @return boolean true si la prueba requiere viento por resultado individual
     * y no por prueba (salto largo,salto triple por ejemplo).
     */
    public function get_apppruebas_viento_individual() {
        return $this->apppruebas_viento_individual;
    }

    /**
     * Setea si la prueba requiere viento por resultado individual
     * y no por prueba (salto largo,salto triple por ejemplo).
     *
     * @param boolean $apppruebas_viento_individual
     */
    public function set_apppruebas_viento_individual($apppruebas_viento_individual) {
        if ($apppruebas_viento_individual !== 'true' && $apppruebas_viento_individual !== 'TRUE' &&
                $apppruebas_viento_individual !== TRUE && $apppruebas_viento_individual != 't' &&
                $apppruebas_viento_individual != 'T' && $apppruebas_viento_individual != '1') {
            $this->apppruebas_viento_individual = 'false';
        } else {
            $this->apppruebas_viento_individual = 'true';
        }
    }

    /**
     *
     * @return double el limite de viento permitido en pruebas no multiples
     * o combinadas.
     */
    public function get_apppruebas_viento_limite_normal() {
        return $this->apppruebas_viento_limite_normal;
    }

    /**
     * Setea el limite de viento permitido en pruebas no multiples
     * o combinadas.
     *
     * @param double $apppruebas_viento_limite_normal
     */
    public function set_apppruebas_viento_limite_normal($apppruebas_viento_limite_normal) {
        $this->apppruebas_viento_limite_normal = $apppruebas_viento_limite_normal;
    }

    /**
     *
     * @return double el limite de viento permitido en pruebas multiples
     * o combinadas.
     */
    public function get_apppruebas_viento_limite_multiple() {
        return $this->apppruebas_viento_limite_multiple;
    }

    /**
     * Setea el limite de viento permitido en pruebas multiples
     * o combinadas.
     *
     * @param double set_apppruebas_viento_limite_multiple
     */
    public function set_apppruebas_viento_limite_multiple($apppruebas_viento_limite_multiple) {
        $this->apppruebas_viento_limite_multiple = $apppruebas_viento_limite_multiple;
    }

    /**
     * Retorna el numero de atletas que componen una prueba , basicamente
     * para los casos de las postas en que son 4.
     *
     * @return integer el numero de atletas
     */
    public function get_apppruebas_nro_atletas() {
        return $this->apppruebas_nro_atletas;
    }

    /**
     * Setea el numero de atletas que componen una prueba , basicamente
     * para los casos de las postas en que son 4.
     *
     * @param integer $apppruebas_nro_atletas el numero de atletas
     */
    public function set_apppruebas_nro_atletas($apppruebas_nro_atletas) {
        $this->apppruebas_nro_atletas = $apppruebas_nro_atletas;
    }

    /**
     * Retorna el factor de correccion de electronico a manual
     * de las marcas que corresponden a esta prueba.
     *
     * @return float con el factor de correccion
     */
    public function get_apppruebas_factor_manual() {
        return $this->apppruebas_factor_manual;
    }

    /**
     * Setea el factor de correccion de electronico a manual
     * de las marcas que corresponden a esta prueba.
     *
     * @param float $apppruebas_factor_manual con el factor de correccion
     */
    public function set_apppruebas_factor_manual($apppruebas_factor_manual) {
        $this->apppruebas_factor_manual = $apppruebas_factor_manual;
    }

    public function &getPKAsArray() {
        $pk['apppruebas_codigo'] = $this->getId();
        return $pk;
    }

}

?>