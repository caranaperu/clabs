<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los valores de validacion para las categorias
 * de atletas , digase mayores , menores , etc , donde se indicara el peso relativo de una
 * con la otra , digamos pesara mas la que su record sea de mayor valor , por ejemplo mayores pesara mas que menores.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: AppCategoriasModel.php 68 2014-03-09 10:19:20Z aranape $
 * @history ''
 *
 * $Date: 2014-03-09 05:19:20 -0500 (dom, 09 mar 2014) $
 * $Rev: 68 $
 */
class AppCategoriasModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $appcat_codigo;
    protected $appcat_peso;

    /**
     * Setea el codigo que representara una validacion de la categoria.
     *
     * @param string $appcat_codigo codigo que representara una validacion de la categoria.
     */
    public function set_appcat_codigo($appcat_codigo) {
        $this->appcat_codigo = $appcat_codigo;
        $this->setId($appcat_codigo);
    }

    /**
     * @return string retorna el codigo que representara una validacion de la categoria.
     */
    public function get_appcat_codigo() {
        return $this->appcat_codigo;
    }

    /**
     * Setea el peso relativo de la categoria con respecto a las otras , mayor peso
     * mas relevante la marca , por ejemplo la marca de mayores debera tener un peso mayor a
     * la marca de menores.
     *
     * @param int $appcat_peso peso relativo de la categoria,
     */
    public function set_appcat_peso($appcat_peso) {
        $this->appcat_peso = $appcat_peso;
    }

    /**
     *
     * @return int eso relativo de la categoria,
     */
    public function get_appcat_peso() {
        return $this->appcat_peso;
    }



    public function &getPKAsArray() {
        $pk['appcat_codigo'] = $this->getId();
        return $pk;
    }

}

?>