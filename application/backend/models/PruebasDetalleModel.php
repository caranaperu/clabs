<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo para definir las pruebas que conforman una principal , esto sera
 * usado solo para las pruebas combinadas.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: PruebasDetalleModel.php 74 2014-03-09 10:24:37Z aranape $
 * @history ''
 *
 * $Date: 2014-03-09 05:24:37 -0500 (dom, 09 mar 2014) $
 * $Rev: 74 $
 */
class PruebasDetalleModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $pruebas_detalle_id;
    protected $pruebas_codigo;
    protected $pruebas_detalle_prueba_codigo;
    protected $pruebas_detalle_orden;

    /**
     * Setea el id unico de la relacion pruebas-pruebas  detalle (combinadas)
     *
     * @param integer $pruebas_detalle_id unico de la relacion pruebas-pruebas  detalle (combinadas)
     */
    public function set_pruebas_detalle_id($pruebas_detalle_id) {
        $this->pruebas_detalle_id = $pruebas_detalle_id;
        $this->setId($pruebas_detalle_id);
    }

    /**
     * @return integer retorna el id unico de la relacion pruebas-pruebas  detalle (combinadas)
     */
    public function get_pruebas_detalle_id() {
        return $this->pruebas_detalle_id;
    }

    /**
     * Setea el codigo de la prueba a relacionar
     *
     * @param string $pruebas_codigo codigo de la prueba a relacionar
     */
    public function set_pruebas_codigo($pruebas_codigo) {
        $this->pruebas_codigo = $pruebas_codigo;
    }

    /**
     *
     * @return string con el codigo de la prueba a relacionar
     */
    public function get_pruebas_codigo() {
        return $this->pruebas_codigo;
    }

    /**
     * Setea el codigo de la prueba que sera parte de la principal , por ejemplo
     * lanzamiento de bala para la prueba principal heptathlon.
     *
     * @param string $pruebas_detalle_prueba_codigo codigo de la prueba parte de la principal
     */
    public function set_pruebas_detalle_prueba_codigo($pruebas_detalle_prueba_codigo) {
        $this->pruebas_detalle_prueba_codigo = $pruebas_detalle_prueba_codigo;
    }

    /**
     *
     * @return string retorna el codigo de la prueba parte de la principal
     */
    public function get_pruebas_detalle_prueba_codigo() {
        return $this->pruebas_detalle_prueba_codigo;
    }

    /**
     * Indica el orden en que se efectua esta prueba con respecto a las demas
     * que componen la principal , por ejemplo los 100 con vallas del heptatlon
     * tiene orden 1 , la bala 3 , etc
     *
     * @param int $pruebas_detalle_orden el orden de la prueba con respecto a las demas
     */
    public function set_pruebas_detalle_orden($pruebas_detalle_orden) {
        $this->pruebas_detalle_orden = $pruebas_detalle_orden;
    }

    /**
     *
     * @return int el orden de la prueba con respecto a las demas
     */
    public function get_pruebas_detalle_orden() {
        return $this->pruebas_detalle_orden;
    }


    public function &getPKAsArray() {
        $pk['pruebas_detalle_id'] = $this->getId();
        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return boolean true
     */
    public function isPKSequenceOrIdentity() {
        return true;
    }

}

?>