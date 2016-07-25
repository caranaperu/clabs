<?php

if (!defined('BASEPATH'))
    exit('No direct script access allowed');

/**
 * Modelo  para definir los usuarios del sistema
 *
 * @author  $Author: aranape@gmail.com $
 * @since   06-FEB-2013
 * @version $Id: UsuariosModel.php 57 2015-08-23 22:46:22Z aranape@gmail.com $
 * @history ''
 *
 * $Date: 2015-08-23 17:46:22 -0500 (dom, 23 ago 2015) $
 * $Rev: 57 $
 */
class UsuariosModel extends \app\common\model\TSLAppCommonBaseModel {

    protected $usuarios_id;
    protected $usuarios_code;
    protected $usuarios_password;
    protected $usuarios_nombre_completo;
    protected $usuarios_admin;

    public function set_usuarios_id($usuarios_id) {
        $this->usuarios_id = $usuarios_id;
        $this->setId($usuarios_id);
    }

    public function get_usuarios_id() {
        return $this->usuarios_id;
    }

    /**
     * Setea el codigo unico del usuario
     *
     * @param string $usuarios_code
     */
    public function set_usuarios_code($usuarios_code) {
        $this->usuarios_code = $usuarios_code;
    }

    /**
     *
     * @return string con el codigo unico del usuario
     */
    public function get_usuarios_code() {
        return $this->usuarios_code;
    }

    /**
     * Setea el password del usuario, el formato debe ser texto este puede o no
     * estar encriptado y dependera de la implementacion.
     *
     * @param string $usuarios_password
     */
    public function set_usuarios_password($usuarios_password) {
        $this->usuarios_password = $usuarios_password;
    }

    /**
     * Retorna el password del usuario , este puede o no estar encriptado
     * dependiendo de la instalacion.
     *
     * @return string
     */
    public function get_usuarios_password() {
        return $this->usuarios_password;
    }

    /**
     * Setea el nombre completo del usuario.
     *
     * @param string $usuarios_nombre_completo
     */
    public function set_usuarios_nombre_completo($usuarios_nombre_completo) {
        $this->usuarios_nombre_completo = $usuarios_nombre_completo;
    }

    /**
     *
     * @return string con el nombre completo del usuario
     */
    public function get_usuarios_nombre_completo() {
        return $this->usuarios_nombre_completo;
    }

    /**
     * Setea si un usuario es administrador
     *
     * @param boolean $usuarios_admin true si es administrados.
     */
    public function set_usuarios_admin($usuarios_admin) {
        $this->usuarios_admin = UsuariosModel::getAsBool($usuarios_admin);
    }

    /**
     * Retorna true si es admin y false si no lo es
     *
     * @return boolean
     */
    public function get_usuarios_admin() {
        return $this->usuarios_admin;
    }

    public function &getPKAsArray() {
        $pk['usuarios_id'] = $this->getId();
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