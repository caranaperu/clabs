<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las tipos de insumos a utilizar en una composicion
 * o mezcla.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: RegionesModel.php 268 2014-06-27 18:11:45Z aranape $
 * @history ''
 *
 * $Date: 2014-06-27 13:11:45 -0500 (vie, 27 jun 2014) $
 * $Rev: 268 $
 */
class TipoInsumoModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $tinsumo_codigo;
    protected $tinsumo_descripcion;

    /**
     * Setea el codigo unico del tipo de insumo.
     *
     * @param string $tinsumo_codigo codigo  unico del tipo de insumo
     */
    public function set_tinsumo_codigo($tinsumo_codigo) {
        $this->tinsumo_codigo = $tinsumo_codigo;
        $this->setId($tinsumo_codigo);
    }

    /**
     * @return string retorna el codigo unico del tipo de insumo.
     */
    public function get_tinsumo_codigo() {
        return $this->tinsumo_codigo;
    }

    /**
     * Setea el nombre del tipo de insumo.
     *
     * @param string $tinsumo_descripcion nombre del tipo de insumo.
     */
    public function set_tinsumo_descripcion($tinsumo_descripcion) {
        $this->tinsumo_descripcion = $tinsumo_descripcion;
    }

    /**
     *
     * @return string con el nombre del tipo de insumo.
     */
    public function get_tinsumo_descripcion() {
        return $this->tinsumo_descripcion;
    }


    public function &getPKAsArray() {
        $pk['tinsumo_codigo'] = $this->getId();
        return $pk;
    }

}

?>