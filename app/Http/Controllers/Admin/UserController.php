<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;


class UserController extends Controller
{
    public function index()
    {
        $users = User::paginate(20);//User::all();
        

        return view('admin.users.index',compact('users')) ;
        
    }
    
    public function create()
    {
        return view('admin.users.create');
    }

    public function store(Request $request)
    {

        User::create($request->all());

        return redirect()->route('users.index');
    }

} 