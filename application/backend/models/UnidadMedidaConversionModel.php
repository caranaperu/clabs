<?php


if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo de entidad fisica que representa los datos de las conversiones
 * entre 2 unidades de medida.
 *
 * @author $Author: aranape $
 * @version $Id: EntidadModel.php 7 2014-02-11 23:55:54Z aranape $
 * @history , ''
 *
 * $Rev: 7 $
 * $Date: 2014-02-11 18:55:54 -0500 (mar, 11 feb 2014) $
 */
class UnidadMedidaConversionModel extends \app\common\model\TSLAppCommonBaseModel
{

    protected $unidad_medida_conversion_id;
    protected $unidad_medida_origen;
    protected $unidad_medida_destino;
    protected $unidad_medida_conversion_factor;


    public function set_unidad_medida_conversion_id($unidad_medida_conversion_id)
    {
        $this->unidad_medida_conversion_id = $unidad_medida_conversion_id;
        $this->setId($unidad_medida_conversion_id);
    }

    public function get_unidad_medida_conversion_id()
    {
        return $this->unidad_medida_conversion_id;
    }

    /**
     * Setea el codigo de la unidad de medida origen de conversion.
     *
     * @param $unidad_medida_origen codigo de la unidad de medida origen de conversion.
     */
    public function set_unidad_medida_origen($unidad_medida_origen)
    {
        $this->unidad_medida_origen = $unidad_medida_origen;
    }


    /**
     * Retorna el codigo de la unidad de medida origen de conversion.
     *
     * @return string codigo de la unidad de medida origen de conversion.
     */
    public function get_unidad_medida_origen()
    {
        return $this->unidad_medida_origen;
    }

    /**
     * Setea el codigo de la unidad de medida destino de conversion.
     *
     * @param $unidad_medida_origen codigo de la unidad de medida destino de conversion.
     */
    public function set_unidad_medida_destino($unidad_medida_destino)
    {
        $this->unidad_medida_destino = $unidad_medida_destino;
    }


    /**
     * Retorna el codigo de la unidad de medida destino de conversion.
     *
     * @return string codigo de la unidad de medida destino de conversion.
     */
    public function get_unidad_medida_destino()
    {
        return $this->unidad_medida_destino;
    }

    /**
     * Setea el factor de conversion entre la unidad de medida y destino.
     *
     * @param $unidad_medida_conversion_factor factor de conversion entre la unidad de medida y destino.
     */
    public function set_unidad_medida_conversion_factor($unidad_medida_conversion_factor)
    {
        $this->unidad_medida_conversion_factor = $unidad_medida_conversion_factor;
    }


    /**
     * Retorna el factor de conversion entre la unidad de medida y destino.
     *
     * @return double con el factor de conversion.
     */
    public function get_unidad_medida_conversion_factor()
    {
        return $this->unidad_medida_conversion_factor;
    }


    public function &getPKAsArray()
    {
        $pk['unidad_medida_conversion_id'] = $this->getId();
        return $pk;
    }

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return boolean true
     */
    public function isPKSequenceOrIdentity()
    {
        return true;
    }

}

?>