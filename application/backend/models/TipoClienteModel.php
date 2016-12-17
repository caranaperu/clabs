<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los tipos de clientes
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: UnidadMedidaModel.php 136 2014-04-07 00:31:52Z aranape $
 * @history ''
 *
 * $Date: 2014-04-06 19:31:52 -0500 (dom, 06 abr 2014) $
 * $Rev: 136 $
 */
class TipoClienteModel extends \app\common\model\TSLAppCommonBaseModel
{

    protected $tipo_cliente_codigo;
    protected $tipo_cliente_descripcion;

    /**
     * Setea el codigo del tipo de cliente.
     *
     * @param string $tipo_cliente_codigo codigo unico del tipo de cliente.
     */
    public function set_tipo_cliente_codigo($tipo_cliente_codigo)
    {
        $this->tipo_cliente_codigo = $tipo_cliente_codigo;
        $this->setId($tipo_cliente_codigo);
    }

    /**
     * @return string retorna el codigo unico del tipo de cliente.
     */
    public function get_tipo_cliente_codigo()
    {
        return $this->tipo_cliente_codigo;
    }

    /**
     * Setea la descripcion del tipo de cliente.
     *
     * @param string $tipo_cliente_descripcion la descrpcion del tipo cliente.
     */
    public function set_tipo_cliente_descripcion($tipo_cliente_descripcion)
    {
        $this->tipo_cliente_descripcion = $tipo_cliente_descripcion;
    }

    /**
     *
     * @return string la descripcion del tipo de cliente.
     */
    public function get_tipo_cliente_descripcion()
    {
        return $this->tipo_cliente_descripcion;
    }


    public function &getPKAsArray()
    {
        $pk['tipo_cliente_codigo'] = $this->getId();
        return $pk;
    }

}

?>