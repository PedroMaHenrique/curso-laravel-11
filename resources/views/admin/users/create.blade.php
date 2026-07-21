<h1>Novo Usuário</h1>

<form action="{{route('users.store')}}" method="POST">
    @csrf()
    <input type="text" name="_token" value="{{csrf_token()}}">
    <input type="text" name="name" placeholder="Nome">
    <input type="email" name="email" placeholder="E-mail">
    <input type="password" name="password" placeholder="senha">

    <button type= "submit">Enviar</button>

</form>