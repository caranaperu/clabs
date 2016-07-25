<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir las unidades de medida
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: UnidadMedidaModel.php 136 2014-04-07 00:31:52Z aranape $
 * @history ''
 *
 * $Date: 2014-04-06 19:31:52 -0500 (dom, 06 abr 2014) $
 * $Rev: 136 $
 */
class UnidadMedidaModel extends \app\common\model\TSLAppCommonBaseModel
{

    protected $unidad_medida_codigo;
    protected $unidad_medida_siglas;
    protected $unidad_medida_descripcion;
    protected $unidad_medida_tipo;
    protected $unidad_medida_protected;
    private static $_UM_TIPO = array('P', 'V', 'L');

    /**
     * Setea el codigo de la unidad de medida
     *
     * @param string $unidad_medida_codigo codigo unico de la unidad de medida
     */
    public function set_unidad_medida_codigo($unidad_medida_codigo)
    {
        $this->unidad_medida_codigo = $unidad_medida_codigo;
        $this->setId($unidad_medida_codigo);
    }

    /**
     * @return string retorna el codigo unico de la unidad de medida
     */
    public function get_unidad_medida_codigo()
    {
        return $this->unidad_medida_codigo;
    }

    /**
     * Setea las siglas de la unidad de medida
     *
     * @param string $unidad_medida_siglas siglas de la unidad de medida
     */
    public function set_unidad_medida_siglas($unidad_medida_siglas)
    {
        $this->unidad_medida_siglas = $unidad_medida_siglas;
    }

    /**
     * @return string retorna las siglas de la unidad de medida
     */
    public function get_unidad_medida_siglas()
    {
        return $this->unidad_medida_siglas;
    }

    /**
     * Setea la descrpcion de la unidad de medida
     *
     * @param string $unidad_medida_descripcion la descrpcion de la unidad de medida
     */
    public function set_unidad_medida_descripcion($unidad_medida_descripcion)
    {
        $this->unidad_medida_descripcion = $unidad_medida_descripcion;
    }

    /**
     *
     * @return string la descripcion de la unidad de medida
     */
    public function get_unidad_medida_descripcion()
    {
        return $this->unidad_medida_descripcion;
    }


    /**
     * Los valores que retorna como tipo de unidad de medida son:
     *      'P' - Peso
     *      'V' - Volumen
     *      'L' - Longitud
     *
     * @return char el tipo de unidad de medida,, null si no esta
     * bien definido.
     */
    public function get_unidad_medida_tipo()
    {
        return $this->unidad_medida_tipo;
    }

    /**
     * Setea  el tipo de unidad de medida, los cuales pueden ser
     *      'P' - Peso
     *      'V' - Volumen
     *      'L' - Longitud
     * @param char $unidad_medida_tipo con el tipo
     */
    public function set_unidad_medida_tipo($unidad_medida_tipo)
    {
        $unidad_medida_tipo_u = strtoupper($unidad_medida_tipo);

        if (in_array($unidad_medida_tipo_u, UnidadMedidaModel::$_UM_TIPO)) {
            $this->unidad_medida_tipo = $unidad_medida_tipo_u;
        } else {
            $this->unidad_medida_tipo = null;
        }
    }

    /**
     * Indica si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @return boolean
     */
    public function get_unidad_medida_protected()
    {
        return $this->unidad_medida_protected;
    }

    /**
     * Setea si es un registro protegido, la parte cliente no administrativa
     * debe validar que si este campo es TRUE solo puede midificarse por el admin.
     *
     * @param boolean $categorias_protected
     */
    public function set_unidad_medida_protected($unidad_medida_protected)
    {
        $this->unidad_medida_protected = $unidad_medida_protected;
    }

    public function &getPKAsArray()
    {
        $pk['unidad_medida_codigo'] = $this->getId();
        return $pk;
    }

}

?>