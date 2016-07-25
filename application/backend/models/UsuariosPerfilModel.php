<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los perfiles que se asocian a un usuario
 * para cada sistema.
 *
 * @author  $Author: aranape $
 * @since   06-FEB-2013
 * @version $Id: UsuariosPerfilModel.php 388 2014-01-11 09:17:22Z aranape $
 * @history ''
 *
 * $Date: 2014-01-11 04:17:22 -0500 (sáb, 11 ene 2014) $
 * $Rev: 388 $
 */
class UsuariosPerfilModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $usuario_perfil_id;
    protected $usuarios_id;
    protected $perfil_id;

    public function set_usuario_perfil_id($usuario_perfil_id) {
        $this->usuario_perfil_id = $usuario_perfil_id;
        $this->setId($usuario_perfil_id);
    }

    public function get_usuario_perfil_id() {
        return $this->usuario_perfil_id;
    }

    /**
     * Retorna el unique id del usuario al que se asociara el perfil
     * identificado por $perfil_id.
     *
     * @return int el id del usuario al que se le asocia el perfil
     */
    public function get_usuarios_id() {
        return $this->usuarios_id;
    }

    /**
     * Setea el unique id del usuario al que se asociara el perfil
     * identificado por $perfil_id.
     *
     * @param int $usuarios_id el id unico del usuario al que se asocian los
     * perfiles.
     */
    public function set_usuarios_id($usuarios_id) {
        $this->usuarios_id = $usuarios_id;
    }

    /**
     *
     * @return int el id unico del perfil a asociar al usuario
     */
    public function get_perfil_id() {
        return $this->perfil_id;
    }

    /**
     * Setea el unique id del perfil a asociar al usuario.
     *
     * @param int $perfil_id con el unique id del perfil
     */
    public function set_perfil_id($perfil_id) {
        $this->perfil_id = $perfil_id;
    }



/*    public function getUniqueCode() {
        return $this->get_usuario_perfil_id();
    }*/

    /**
     * Indica que su pk o id es una secuencia o campo identity
     *
     * @return boolean true
     */
    public function isPKSequenceOrIdentity() {
        return true;
    }

    public function &getPKAsArray() {
        $pk['usuario_perfil_id'] = $this->getId();
        return $pk;
    }

}

?>